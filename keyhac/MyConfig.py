# coding: utf-8
from keyhac import *
import pyauto

class MyConfig:
    '''
    個人設定。このクラスのコンストラクタを呼び出すと、自動的に設定を完了する。
    例:
        def configure(km):
            MyConfig(km)
    '''
    # イニシャライザ
    def __init__(self, km):
        self.km = km
        self.kmg = km.defineWindowKeymap()
        self.commands = '''
            base hhk hhk_others diamond_cursor
            ckw putty teraterm gvim firefox excel
            emacs aero_snap
            limechat
        '''.split()

        for com in self.commands:
            getattr(self, com)()

    # 指定したexe名でkmを取り出す
    def km_for_exe(self, exe):
        return self.km.defineWindowKeymap(exe_name = exe)

    # マルチストローク設定
    def set_multistroke(self, command, func, modifier = "C"):
        def set_default(d, i, value = self.km.defineMultiStrokeKeymap()):
            def make_key(s):
                return modifier + "-" + command[s]
            try:
                d[make_key(i)]
            except:
                d[make_key(i)] = value
            return d[make_key(i)]

        for i in xrange(len(command)):
            if i == 0:
                km_ms = set_default(self.kmg, 0)
            elif i < len(command) - 1:
                km_ms = set_default(km_ms, i)
            else:
                set_default(km_ms, -1, func)

    # 基本設定
    def base(self):
        # 設定をリロードする
        self.kmg["C-A-R"] = self.km.command_ReloadConfig

    # 英語配列化（HHK用）
    def hhk(self):
        # S-2 => @
        self.kmg["S-2"] = "(192)"
        # S-6 => ^
        self.kmg["S-6"] = "(222)"
        # S-7 => &
        self.kmg["S-7"] = "S-6"
        # S-8 => *
        self.kmg["S-8"] = "S-(186)"
        # S-9 =>)
        self.kmg["S-9"] = "S-8"
        # S-0 =>)
        self.kmg["S-0"] = "S-9"
        # S-- => _
        self.kmg["S-Minus"] = "S-(226)"
        # ^ => =
        self.kmg["(222)"] = "S-Minus"
        # S-^ => +
        self.kmg["S-(222)"] = "S-Plus"
        # [=> \
        # S-[=> |
        self.km.replaceKey("(221)", "(220)")
        # 半角/全角 => `
        self.kmg["(243)"] = "S-(192)"
        self.kmg["(244)"] = "S-(192)"
        # S-半角/全角 => ~
        self.kmg["S-(243)"] = "S-(222)"
        self.kmg["S-(244)"] = "S-(222)"
        # 半角/全角 => Esc
        #self.kmg["(243)"] = "Esc"
        #self.kmg["(244)"] = "Esc"
        # S-半角/全角 => S-Esc
        #self.kmg["S-(243)"] = "S-Esc"
        #self.kmg["S-(244)"] = "S-Esc"
        # Backspace => `
        #self.kmg["Back"] = "S-(192)"
        # S-Backspace => ~
        #self.kmg["S-Back"] = "S-(222)"
        # C-Backspace => C-`
        #self.kmg["C-Back"] = "C-S-(192)"
        # @ => [
        # S-@ => {
        self.km.replaceKey("(192)", "(219)")
        # [=>]
        # S-[=> }
        self.km.replaceKey("(219)", "(221)")
        # S-; => :
        self.kmg["S-Plus" ] = "(186)"
        # : => '
        self.kmg["(186)" ] = "S-7"
        # S-: => "
        self.kmg["S-(186)" ] = "S-2"

    # HHK向けその他の設定
    def hhk_others(self):
        # SandS
        # http://d.hatena.ne.jp/mobitan/20081128/1227792452
        self.km.replaceKey("Space", "LShift")
        self.kmg["O-LShift"] = "Space"

        # C-Space => S-Space
        self.kmg["C-(226)"] = "S-Space"

        # ユーザモディファイアキーの定義
        self.km.defineModifier(235, "User0")
        self.km.defineModifier(236, "User1")

        # O-LWin => Tab
        #self.kmg["O-LWin"] = "Tab"
        # S-LWin => S-Tab
        #self.kmg["S-LWin"] = "S-Tab"

        # O-無変換 => User0
        #self.km.replaceKey("(29)", 235)
        #self.kmg["O-(235)" ] = "(29)"

        ## O-変換 => User1
        #self.km.replaceKey("(28)", 236)
        #self.kmg["O-(236)"] = "(28)"

        # RShift => RCtrl
        # O-RShift => 変換
        #self.km.replaceKey("RShift", "RCtrl")
        #self.kmg["O-RCtrl"] = "28"
        # O-RShift => C-無変換
        self.kmg["O-RShift"] = "C-(29)"

        # Esc => U0
        # O-Esc => Esc
        self.km.replaceKey("Escape", 235)
        self.kmg["O-(235)"] = "Escape"
        # RAlt => U0
        #self.km.replaceKey("RAlt", 235)

        # RCtrl => RWin
        #self.km.replaceKey("RCtrl", "RWin")

        # Backspace => Backslash
        #self.km.replaceKey("BS", "(220)")

        # ファンクションキー
        for i in xrange(10):
            self.kmg["LC-" + str(i+ 1)] = "F" + str(i + 1)

        self.kmg["LC-Minus"] = "F11"
        self.kmg["LC-(222)"] = "F12"

        # クリップボード履歴
        self.kmg["U0-Z"] = self.km.command_ClipboardList
        self.kmg["U0-X"] = self.km.command_ClipboardRotate
        self.kmg["U0-C"] = self.km.command_ClipboardRemove
        self.km.quote_mark = "> "

        # Backspace => \
        self.km.replaceKey("Back", "(220)")
        # Delete => Backspace
        self.km.replaceKey("Delete", "Back")

        #{{{
        # RWin => 全角/半角
        # O-RWin => RCtrl
        #self.km.replaceKey("RWin", "RCtrl")
        #self.kmg["O-RCtrl"] = "(243)"
        #elf.kmg["O-RCtrl"] = "A-(25)"
        # O-RWin => 変換
        self.kmg["RWin"] = "(255)"
        self.kmg["O-RWin"] = "(28)"

        # LAlt => LCtrl
        # LWin => LAlt
        #self.km.replaceKey("LAlt", "LCtrl")
        #self.km.replaceKey("LWin", "LAlt")

        ## LWin => 英数
        # LWin => 無変換
        # O-LWin => LWin
        # S-LWin => S-無変換
        # C-LWin => C-無変換
        # C-S-LWin => C-S-無変換
        #self.km.replaceKey("LWin", 29)
        #self.kmg["O-(235)"] = "(240)"
        self.kmg["LWin"] = "(255)"
        self.kmg["O-LWin"] = "(29)"
        self.kmg["S-LWin"] = "S-(29)"
        self.kmg["C-LWin"] = "C-(29)"
        self.kmg["C-S-LWin"] = "C-S-(29)"

        # LAlt => C-無変換
        # O-LAlt => LAlt
        self.kmg["O-LAlt"] = "C-(29)"
        self.kmg["LAlt"] = "LAlt"

        # LCtrl => 英数
        #self.km.replaceKey("LCtrl", 29)

        # 変換 => 全角/半角
        # O-変換 => RCtrl
        #self.km.replaceKey(28, "RCtrl")
        #self.kmg["O-RCtrl"] = "(243)"

        # 無変換 => 英数
        # O-無変換 => RCtrl
        #self.km.replaceKey("(29)", "RCtrl")
        #self.kmg["O-RCtrl" ] = "(29)"

        # ひらがな => 全角/半角
        # O-ひらがな => RCtrl
        # self.km.replaceKey(240, "RCtrl")
        # self.km.replaceKey(242, "RCtrl")
        # self.kmg["O-RCtrl"] = "(243)"

        # CapsLock => LCtrl
        # self.km.replaceKey(240, "LCtrl")
        # LShift => LCtrl
        #self.km.replaceKey("LShift", "LCtrl")
        # 無変換 => LCtrl
        #self.km.replaceKey(29, "LCtrl")

    # ckm用設定
    def ckw(self):
        km = self.km_for_exe(u"ckw.exe")
        km["S-2"] = self.km.command_InputText(u"@")

    #{{{
    def notepad(self):
        km = self.km_for_exe(u"Notepad.exe")
        #km["C-A"] = self.km.command_InputText(u"aiueo")
    #}}}

    # putty用設定
    def putty(self):
        km = self.km_for_exe(u"PUTTY.EXE")

        # ウィンドウ切り替え
        for i in xrange(10):
            km["LC-" + str(i)] = self.km.command_InputKey("LC-Z", str(i))
        # C-Tab でウィンドウ移動
        #km["LC-LWin"] = self.km.command_InputKey("LC-Z", "Tab")
        km["LC-Tab"] = self.km.command_InputKey("LC-Z", "Tab")
        # U0/U1-Space でウィンドウ切り替え
        #km["U0-LShift"] = self.km.command_InputKey("LC-Z", "N")
        #km["U1-LShift"] = self.km.command_InputKey("LC-Z", "P")

        # Putty上ではESC => ESC+日本語入力オフ（無変換）
        #km["ESC"] = self.km.command_InputKey("(29)", "ESC")
        km["(235)"] = self.km.command_InputKey("ESC", "(29)")
        km["C-(219)"] = self.km.command_InputKey("ESC", "(29)")
        #km["(243)"] = self.km.command_InputKey("(29)", "ESC")
        #km["(244)"] = self.km.command_InputKey("(29)", "ESC")

        # putty上ではEmacs風割り当てを解除
        km["C-S"] = "C-S"
        km["C-R"] = "C-R"
        km["C-W"] = "C-W"
        km["C-X"] = "C-X"

        # putty + vim
        # map <F1> :mak!<CR>
        # map <F2> :QFix<CR>
        km["U0-B"] = "F1"
        km["U0-L"] = "F2"
        # タブ切り替え
        km["U0-N"] = self.km.command_InputKey("LC-Z", "LC-N")
        km["U0-P"] = self.km.command_InputKey("LC-Z", "LC-P")
        # コマンドライン
        #km["U0-Plus"] = self.km.command_InputKey("LC-Z", ":")

        # putty + screen
        # ウィンドウ移動
        km["U0-H"] = self.km.command_InputKey("LC-Z", "H")
        km["U0-J"] = self.km.command_InputKey("LC-Z", "J")
        km["U0-K"] = self.km.command_InputKey("LC-Z", "K")
        km["U0-L"] = self.km.command_InputKey("LC-Z", "L")

    # Tera Term用設定
    def teraterm(self):
        km = self.km_for_exe(u"ttermpro.exe")

        # ウィンドウ切り替え
        for i in xrange(10):
            km["LC-" + str(i)] = self.km.command_InputKey("LC-Z", str(i))
        # C-Tab でウィンドウ移動
        km["LC-LWin"] = self.km.command_InputKey("LC-Z", "Tab")
        # U0/U1-Space でウィンドウ切り替え
        #km["U0-LShift"] = self.km.command_InputKey("LC-Z", "N")
        #km["U1-LShift"] = self.km.command_InputKey("LC-Z", "P")

        # Putty上ではESC => ESC+日本語入力オフ（無変換）
        #km["ESC"] = self.km.command_InputKey("(29)", "ESC")
        km["(235)"] = self.km.command_InputKey("(29)", "ESC")

        # putty上ではEmacs風割り当てを解除
        km["C-S"] = "C-S"
        km["C-R"] = "C-R"
        km["C-W"] = "C-W"
        km["C-X"] = "C-X"

        # putty + vim
        # map <F1> :mak!<CR>
        # map <F2> :QFix<CR>
        km["U0-B"] = "F1"
        km["U0-L"] = "F2"
        # タブ切り替え
        km["U0-N"] = self.km.command_InputKey("LC-X", "LC-N")
        km["U0-P"] = self.km.command_InputKey("LC-X", "LC-P")
        # 左右スクロール
        km["U0-L"] = self.km.command_InputKey("z", "l")
        km["U0-H"] = self.km.command_InputKey("z", "h")
        # コマンドライン
        #km["U0-Plus"] = self.km.command_InputKey("LC-Z", ":")

    # GVim用設定
    def gvim(self):
        # GVim上ではESC => ESC+日本語入力オフ（無変換）
        # これは事前に IME の設定が必要
        km = self.km_for_exe(u"gvim.exe")
        #km["ESC"] = self.km.command_InputKey("(29)", "ESC")
        km["(235)"] = self.km.command_InputKey("(29)", "ESC")

        # GVim上ではEmacs風割り当てを解除
        km = self.km_for_exe(u"gvim.exe")
        km["C-S"] = "C-S"
        km["C-R"] = "C-R"
        km["C-W"] = "C-W"
        km["C-X"] = "C-X"

    # Firefox用設定
    def firefox(self):
        km = self.km_for_exe(u"firefox.exe")

        # Firefox上ではEmacs風割り当てを解除
        km["C-S"] = "C-S"
        km["C-R"] = "C-R"
        km["C-W"] = "C-W"
        km["C-X"] = "C-X"

        # ファンクションキー割り当てを解除
        for i in xrange(10):
            km["C-" + str(i)] = "C-" + str(i)

        # タブグループ
        km["C-S-E"] = "C-S-E"
        km["C-(243)"] = "C-S-(192)"
        km["C-(244)"] = "C-S-(192)"

    # Limechat 用の設定
    def limechat(self):
        km = self.km_for_exe(u"LimeChat2.exe")
        km["U0-P"] = "C-Up"
        km["U0-N"] = "C-Down"

    # iBBDemo2 用の設定
    def ibbdemo2(self):
        km = self.km_for_exe(u"iBBDemo2.exe")
        km["C-1"] = "C-1"
        km["C-2"] = "C-2"
        km["C-D"] = "C-D"

    # ダイアモンドカーソル
    def diamond_cursor(self):
        e_cursor = dict(
                B = "Left"
                ,F = "Right"
                ,P = "Up"
                ,N = "Down"
                ,A = "Home"
                ,E = "End"
                ,H = "Back"
                ,D = "Delete"
                #,J = "PageDown"
                #,K = "PageUp"
               )

        # ホイール設定
        wheel_up = self.km.command_MouseWheel(-3.0)
        wheel_down = self.km.command_MouseWheel(3.0)
        self.kmg["U0-J"] = wheel_down
        self.kmg["U0-K"] = wheel_up

        for k in e_cursor.keys():
            self.kmg["LC-" + k] = e_cursor[k]
            self.kmg["LC-S-" + k] = "S-" + e_cursor[k]
            self.kmg["U0-" + k] = e_cursor[k]
            self.set_multistroke("X" + k, "C-" + k)

        # カーソル移動無効化
        for exe in ["ckw" ,"gvim" ,"firefox" ,"putty", "mintty"]:
            exe_name = unicode(exe) + u".exe"
            km = self.km_for_exe(exe_name)
            for k in e_cursor.keys():
                km["LC-" + k] = "LC-" + k
                km["LC-S-" + k] = "LC-S-" + k

    # Excel用設定
    def excel(self):
        km = self.km_for_exe(u"EXCEL.EXE")
        km["F1"] = "C-PageUp"
        km["LC-F1"] = "C-PageUp"
        km["LC-F2"] = "C-PageDown"
        km["LC-U"] = "LC-U"
        km["LC-D"] = "LC-D"

    # VirtualPC 用の設定
    def virtualpc(self):
        km = self.km_for_exe(u"VMWindow.exe")
        km["O-LWin"] = "O-LWin"
        km["S-LWin"] = "S-LWin"

    # Emacs風の動作
    def emacs(self):
        # 検索
        self.kmg["C-S"] = "C-F"
        # 置換
        self.kmg["C-R"] = "C-H"
        # 切り取り
        self.kmg["C-W"] = "C-X"
        # 開く
        self.set_multistroke("XF", "C-O")
        # 上書き保存
        self.set_multistroke("XS", "C-S")
        # 名前をつけて保存
        self.set_multistroke("XW", ("A-F", "A"))
        # 終了
        self.set_multistroke("XC", "A-F4")

        #self.set_multistroke("QUIT", "A-F4")
        #self.set_multistroke("START", "C-O")

    # Windowsキーで選択
    def select_window(self):
        for i in xrange(10):
            self.kmg["LC-" + str(i)] = "LWin-" + str(i)

    # Aeroスナップ
    def aero_snap(self):
        self.kmg["LWin-S"] = "LWin-Left"
        self.kmg["LWin-D"] = "LWin-Down"
        self.kmg["LWin-E"] = "LWin-Up"
        self.kmg["LWin-F"] = "LWin-Right"

    # C-Tabでコンソール関係のウィンドウを切り替え
    # http://sites.google.com/site/craftware/keyhac/tips
    def ctrl_tab(self):
        def isConsoleWindow(wnd):
            if wnd.getClassName() in ("PuTTY", "MinTTY", "CkwWindowClass"):
                return True
            return False

        km = self.km.defineWindowKeymap(check_func = isConsoleWindow)

        def command_SwitchConsole():
            root = pyauto.Window.getDesktop()
            last_console = None

            wnd = root.getFirstChild()
            while wnd:
                if isConsoleWindow(wnd):
                    last_console = wnd
                wnd = wnd.getNext()

            if last_console:
                last_console.setForeground()

        km["C-Tab"] = command_SwitchConsole

# vim:se et ts=4 sts=4 sw=4 fdm=marker:
