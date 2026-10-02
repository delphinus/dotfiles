# Claude Code の横に付く補助ペイン (editprompt / codediff) を見分け、両者を
# 協調させるための共通処理。editprompt.py / codediff.py / close_pane.py /
# pstree.py / watcher.py / tab_bar.py から使う。
#
# レイアウトの約束:
#
#   ┌──────────────┐
#   │ Claude Code  │  ← 相方 (main)。補助ペインでないウィンドウ
#   ├──────────────┤
#   │ editprompt   │  ← ⌘E。相方を hsplit した下に付く
#   ├──────────────┤
#   │ codediff     │  ← ⌘D とフック。画面の下端いっぱいに付く
#   └──────────────┘
#
# editprompt を隠す手段は 2 通りある。
#
#   * codediff が無いとき: stack レイアウトにする (従来どおり)。stack は
#     アクティブなウィンドウだけを映すので、相方へフォーカスすれば editprompt が
#     消える。
#   * codediff があるとき: stack にすると codediff まで一緒に消えてしまう。kitty の
#     splits にはウィンドウを隠す手段が無いので、editprompt の split の bias を 0
#     にして 1 行まで縮める。縮めたことは editprompt 側の user var に残す。
#
# モジュール名を素の `panes` などにしないこと。kitten は exec で読まれるが、ここを
# import した結果は sys.modules に残り、kitty を再起動するまで差し替わらない。
# 他の名前と衝突すると原因を追いにくい。

EDITPROMPT_VAR = "editprompt"
CODEDIFF_VAR = "codediff"

# editprompt を 1 行に縮めて隠していることを示す user var (editprompt 側に付く)。
EDITPROMPT_SQUEEZED_VAR = "editprompt_squeezed"

# editprompt ウィンドウが取る割合 (%)。WezTerm の size = { Cells = 10 } に対し、
# 80 行のウィンドウで概ね同じ高さになる値。
EDITPROMPT_BIAS = 15

# GUI から起動した kitty の PATH は貧弱なので、子プロセスは fish のログイン
# シェル経由で起動して PATH を揃える (open_uri.lua と同じ理由)。
FISH = "/opt/homebrew/bin/fish"


def is_aux(window):
    """補助ペイン (editprompt か codediff) なら True。"""
    v = window.user_vars
    return bool(v.get(EDITPROMPT_VAR) or v.get(CODEDIFF_VAR))


def find(tab):
    """タブ内の相方・editprompt・codediff を返す。居なければ None。"""
    main = editprompt = codediff = None
    for window in tab.windows:
        if window.user_vars.get(EDITPROMPT_VAR):
            editprompt = window
        elif window.user_vars.get(CODEDIFF_VAR):
            codediff = window
        elif main is None:
            main = window
    return main, editprompt, codediff


def tab_of(boss, window_id):
    window = boss.window_id_map.get(window_id)
    if window is None:
        return None
    return boss.tab_for_id(window.tab_id)


def _set_bias(tab, window, bias):
    """window を含む split で、window が占める割合を bias (%) にする。

    layout_action はアクティブなウィンドウに対して働くので、一時的に移して戻す。
    """
    prev = tab.active_window
    tab.set_active_window(window)
    tab.layout_action("bias", [str(bias)])
    if prev is not None and prev is not window:
        tab.set_active_window(prev)


def editprompt_bias(main, codediff, editprompt=None):
    """editprompt の高さがタブ全体の EDITPROMPT_BIAS % 前後になる bias を返す。

    bias は「相方と editprompt の split」の中での割合なので、codediff が下に居て
    その split が半分の高さしか無いと、15 % では 1〜2 行にしかならない。
    """
    if codediff is None:
        return EDITPROMPT_BIAS
    pair = main.screen.lines + (editprompt.screen.lines if editprompt is not None else 0)
    total = pair + codediff.screen.lines
    return max(10, min(90, round(total * EDITPROMPT_BIAS / max(pair, 1))))


def editprompt_hidden(tab, editprompt):
    return tab.current_layout.name == "stack" or bool(editprompt.user_vars.get(EDITPROMPT_SQUEEZED_VAR))


def squeeze_editprompt(tab, editprompt):
    _set_bias(tab, editprompt, 0)
    editprompt.user_vars[EDITPROMPT_SQUEEZED_VAR] = "1"


def resize_editprompt(tab, main, editprompt, codediff):
    """codediff が出入りして高さの前提が変わったときに、editprompt の bias を測り直す。"""
    _set_bias(tab, editprompt, editprompt_bias(main, codediff, editprompt))


def unsqueeze_editprompt(tab, main, editprompt, codediff):
    if editprompt.user_vars.pop(EDITPROMPT_SQUEEZED_VAR, None):
        resize_editprompt(tab, main, editprompt, codediff)


def show_editprompt(tab, main, editprompt, codediff):
    # stack のままだと何をしても見えないので splits に戻してから。
    tab.goto_layout("splits")
    unsqueeze_editprompt(tab, main, editprompt, codediff)
    tab.set_active_window(editprompt)


def hide_editprompt(tab, main, editprompt, codediff):
    # 順序が要る。stack はアクティブなウィンドウを映すので、先に相方へ移して
    # おかないと editprompt が映ったままになる。
    tab.set_active_window(main)
    if codediff is None:
        tab.goto_layout("stack")
    else:
        squeeze_editprompt(tab, editprompt)
