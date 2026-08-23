# 外部コマンドの結果をバックグラウンドで更新し、キャッシュを返す。
#
# WezTerm の update-status は毎秒 tmutil や pmset を同期で叩いていた。kitty の
# draw_tab は描画スレッドで走るので、そこで subprocess を待つとタブバーの描画が
# そのぶん止まる。値の更新だけ別スレッドへ逃がし、描画側はキャッシュを読むだけに
# する。スレッドからは kitty の API を一切触らない (subprocess と文字列だけ)。

import subprocess
import sys
import threading
import time

# 名前ごとの現役の Poller。設定リロードではこのモジュール自体も読み直されるので、
# 登録簿はモジュールの外 (sys の私有キー) に置く。ここに残しておくことで、
# 新しい世代ができたときに前の世代のスレッドへ「もう止まってよい」と伝えられ、
# リロードのたびにスレッドが積み上がるのを防げる。
_live = sys.__dict__.setdefault("_kitty_poller_registry", {})
_live_lock = sys.__dict__.setdefault("_kitty_poller_registry_lock", threading.Lock())


class Poller:
    def __init__(self, name, interval, fn):
        self.name = name
        self.interval = interval
        self.fn = fn
        self._value = None
        self._lock = threading.Lock()
        self._started = False
        self._stale = False
        with _live_lock:
            previous = _live.get(name)
            if previous is not None:
                # 前の世代のスレッドは次のループで抜ける。
                previous._stale = True
            _live[name] = self

    def get(self):
        """最後に取れた値。まだ一度も取れていなければ None。"""
        if not self._started:
            self._started = True
            threading.Thread(target=self._loop, name="poller-" + self.name, daemon=True).start()
        with self._lock:
            return self._value

    def _loop(self):
        while not self._stale:
            try:
                value = self.fn()
            except Exception:
                value = None
            with self._lock:
                self._value = value
            # 世代交代を長く待たせないよう、休みは細かく刻んで見張る。
            slept = 0.0
            while slept < self.interval and not self._stale:
                time.sleep(0.5)
                slept += 0.5


def run(args, timeout=10):
    """コマンドを実行して stdout を返す。失敗したら None。"""
    try:
        proc = subprocess.run(args, capture_output=True, text=True, timeout=timeout)
    except Exception:
        return None
    if proc.returncode != 0:
        return None
    return proc.stdout
