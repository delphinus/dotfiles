# 外部コマンドの結果を少しずつ集めて、最後に取れた値をキャッシュする。
#
# WezTerm の update-status は毎秒 tmutil や pmset を同期で叩いていた。kitty の
# draw_tab は描画のたびに呼ばれるので、そこで subprocess を待つとタブバーの描画が
# そのぶん止まる。
#
# 最初は「別スレッドで叩いてキャッシュを返す」形にしていたが、これは成立しない。
# kitty のプロセスでは Python のスレッドがほとんど進まないため (メインループが
# GIL を握ったままで、スレッド側は数秒に一度しか動けない。実測で別スレッドの
# time.sleep(0.25) が 18.7 秒かかった)、subprocess.run(timeout=...) の timeout が
# 壁時計で先に切れてしまう。数十 ms で終わるはずの tmutil / pmset が軒並み
# TimeoutExpired になり、値が永久に None のまま = ステータスに何も出ない、という
# 状態になっていた。
#
# そこでスレッドは使わず、メインスレッド (描画と add_timer が動くスレッド) だけで
# 回す。コマンドは Popen で投げっぱなしにしておき、次に呼ばれたときに poll() で
# 回収する。待たないので描画は止まらず、GIL の奪い合いも起きない。
#
# 読み方は「argv を yield して stdout を受け取る」ジェネレータで書く。複数の
# コマンドを繋ぐときも、間で描画に制御が戻るだけで見た目は同期コードのままになる:
#
#     def _read():
#         out = yield ["/usr/bin/pmset", "-g", "batt"]  # 失敗したら None が来る
#         return _format(out)

import subprocess
import sys
import tempfile
import time

# 名前ごとの状態。設定リロードではこのモジュール自体も読み直されるので、登録簿は
# モジュールの外 (sys の私有キー) に置く。こうしておくと世代が変わっても、最後に
# 取れた値と進行中のコマンドをそのまま引き継げる。
#
# 以前はここに Poller 自身を入れて「新しい世代ができたら前の世代を止める」形に
# していたが、kitty はモジュールを読み直しても描画に使う関数を 1 回遅れでしか
# 差し替えない。そのため「まだ描画に使われている世代」が「読み込まれただけの
# 新しい世代」に止められ、リロードのたびに表示が死んでいた。
_live = sys.__dict__.setdefault("_kitty_poller_states", {})

# コマンドが返らないまま居座るのを防ぐ。tmutil はバックアップ先がネットワーク越し
# だと十数秒かかることがある (実測でマウントし直しに 26 秒) ので長めに取る。
TIMEOUT = 60


class Poller:
    def __init__(self, name, interval, make):
        """make() は argv を yield して stdout を受け取るジェネレータを返す。

        interval は「前回の読み取りが終わってから次を始めるまで」の秒数。
        """
        state = _live.get(name)
        if state is None:
            state = {"value": None, "gen": None, "proc": None, "out": None, "at": 0.0, "next": 0.0}
            _live[name] = state
        # 世代が変わったら読み方だけ差し替える。battery.py などを直して
        # リロードすれば新しい make() が次の周回から使われる。
        state["make"] = make
        state["interval"] = interval
        self._state = state

    def get(self):
        """最後に取れた値。まだ一度も取れていなければ None。

        ここは描画パスから呼ばれる。進行中のコマンドがあれば poll() するだけ、
        無ければ次を投げるだけで、いずれもブロックしない。
        """
        try:
            _pump(self._state)
        except Exception:
            pass
        return self._state["value"]


def _pump(state):
    now = time.monotonic()
    proc = state["proc"]
    if proc is not None:
        code = proc.poll()
        if code is None:
            if now - state["at"] < TIMEOUT:
                return
            # 返ってこないコマンドは諦める。後始末 (waitpid) は kitty 自身が
            # 全ての子プロセスを刈り取るので任せてよい。
            proc.kill()
            code = -1
        _step(state, _reap(state, code))
        return
    if state["gen"] is None and now >= state["next"]:
        state["gen"] = state["make"]()
        _step(state, None)


def _reap(state, code):
    """走らせていたコマンドの後始末。成功していれば stdout、それ以外は None。"""
    out = state["out"]
    state["proc"] = None
    state["out"] = None
    try:
        if code != 0:
            return None
        out.seek(0)
        return out.read().decode("utf-8", "replace")
    except Exception:
        return None
    finally:
        try:
            out.close()
        except Exception:
            pass


def _step(state, sent):
    """ジェネレータを 1 つ進める。次の argv があれば投げ、終わっていれば値を確定する。"""
    try:
        argv = state["gen"].send(sent)
    except StopIteration as done:
        _rest(state)
        state["value"] = done.value
        return
    except Exception:
        # 読み方の側で落ちた。前の値は残したまま次の周回を待つ。
        _rest(state)
        return
    try:
        # stdout はパイプではなく一時ファイルで受ける。パイプだと誰かが読み続けて
        # いないと出力が詰まるが、ここは投げっぱなしにしたいので読み手が居ない。
        out = tempfile.TemporaryFile()
        state["out"] = out
        state["proc"] = subprocess.Popen(argv, stdout=out, stderr=subprocess.DEVNULL)
        state["at"] = time.monotonic()
    except Exception:
        state["proc"] = None
        state["out"] = None
        _rest(state)


def _rest(state):
    """一周ぶんを終えて、次に始める時刻を決める。"""
    state["gen"] = None
    state["next"] = time.monotonic() + state["interval"]
