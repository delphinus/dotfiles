// [delphinus] Emacs キーバインド
//
// 出自: ke-complex-modifications.pqrs.org から 2023-08-20 に取得した
// 1692495936.json のうち、実際に有効にしていた 3 ルール
//
//   - Emacs key bindings [control+keys] (rev 11)  16 manipulators
//   - Emacs key bindings [option+keys]  (rev 5)    4 manipulators
//   - Bash style Emacs key bindings     (rev 2)    2 manipulators
//
// を JS へ書き直したもの。未使用だった C-x ストロークと VSCode 用の 3 ルールは
// 落としてある (要るときは上流から取り直す)。
//
// 書き直した理由: ダウンロードした JSON を手で書き換えていくと、除外リストが
// 15 箇所へ複製されたまま散らばる。実際コピーが 2 つ (1692495936.json と
// emacs.json) に分かれ、端末ごとに別々のコピーを取り込んでいたため、
// wezterm / ghostty / 画面共有 / Parallels の除外がそれぞれ片方にしか
// 入っていなかった。このファイルは両方の意図の和集合になっている。
//
// 必要バージョン: assets へ .js を置いて読ませるには 16.2.0 以降。
// karabiner.json 側へ eval_js として埋め込むだけなら 16.0.0 以降で動く。
// ECMAScript 5.1 (Duktape) のみ。require() は使えないので単体で完結させる。
// 検証: karabiner_cli --lint-complex-modifications emacs.js

function main() {
  // Emacs 風のキーバインドを送らないアプリ。Emacs 本体、端末エミュレータ、
  // VM / リモートデスクトップのクライアント、Vim 系など、同じキーを自前で
  // 解釈するもの。ここへ足せば全 manipulator に一度で効く。
  var EXCLUDED_APPS = [
    '^org\\.gnu\\.Emacs$',
    '^org\\.gnu\\.AquamacsEmacs$',
    '^org\\.gnu\\.Aquamacs$',
    '^org\\.pqrs\\.unknownapp.conkeror$',
    '^com\\.microsoft\\.rdc$',
    '^com\\.microsoft\\.rdc\\.',
    '^net\\.sf\\.cord$',
    '^com\\.thinomenon\\.RemoteDesktopConnection$',
    '^com\\.itap-mobile\\.qmote$',
    '^com\\.nulana\\.remotixmac$',
    '^com\\.p5sys\\.jump\\.mac\\.viewer$',
    '^com\\.p5sys\\.jump\\.mac\\.viewer\\.',
    '^com\\.teamviewer\\.TeamViewer$',
    '^com\\.vmware\\.horizon$',
    '^com\\.2X\\.Client\\.Mac$',
    '^com\\.OpenText\\.Exceed-TurboX-Client$',
    '^com\\.realvnc\\.vncviewer$',
    '^com\\.citrix\\.receiver\\.icaviewer',
    '^com\\.apple\\.Terminal$',
    '^com\\.googlecode\\.iterm2$',
    '^co\\.zeit\\.hyperterm$',
    '^co\\.zeit\\.hyper$',
    '^io\\.alacritty$',
    '^org\\.alacritty$',
    '^net\\.kovidgoyal\\.kitty$',
    '^org\\.vim\\.',
    '^com\\.qvacua\\.VimR$',
    '^com\\.vmware\\.fusion$',
    '^com\\.vmware\\.horizon$', // 上流由来の重複 (14 番目と同じ)
    '^com\\.vmware\\.view$',
    '^com\\.parallels\\.desktop$',
    '^com\\.parallels\\.vm$',
    '^com\\.parallels\\.desktop\\.console$',
    '^org\\.virtualbox\\.app\\.VirtualBoxVM$',
    '^com\\.citrix\\.XenAppViewer$',
    '^com\\.vmware\\.proxyApp\\.',
    '^com\\.parallels\\.winapp\\.',
    '^com\\.utmapp\\.UTM$',
    '^org\\.x\\.X11$',
    '^com\\.apple\\.x11$',
    '^org\\.macosforge\\.xquartz\\.X11$',
    '^org\\.macports\\.X11$',
    '^com\\.sublimetext\\.',
    '^com\\.microsoft\\.VSCode$',
    '^com\\.github\\.wez\\.wezterm$',
    '^com\\.mitchellh\\.ghostty$',
    // 画面共有の先にあるキーボードへそのまま送るため。
    '^com\\.apple\\.ScreenSharing$',
  ]

  // WezTerm はバンドル ID で拾えないことがあるので実行ファイルでも見る。
  var EXCLUDED_FILE_PATHS = ['/opt/homebrew/bin/wezterm-gui']

  var unlessExcluded = [
    {
      type: 'frontmost_application_unless',
      bundle_identifiers: EXCLUDED_APPS,
      file_paths: EXCLUDED_FILE_PATHS,
    },
  ]

  // EXCLUDED_APPS には Parallels が入っているが、下の Office / Eclipse /
  // キーボード種別で分岐する manipulator はそのリストを使わない。VM の中の
  // 操作に干渉させないよう、そこだけ個別に除外する。
  var unlessParallels = {
    type: 'frontmost_application_unless',
    bundle_identifiers: [
      '^com\\.parallels\\.desktop\\.console$',
      '^com\\.parallels\\.winapp\\.',
    ],
  }

  // macOS が既定で control+a / control+e を行頭・行末にしてくれないアプリ。
  var ifMsOffice = [
    {
      type: 'frontmost_application_if',
      bundle_identifiers: [
        '^com\\.microsoft\\.Excel$',
        '^com\\.microsoft\\.Powerpoint$',
        '^com\\.microsoft\\.Word$',
      ],
    },
    unlessParallels,
  ]
  var ifEclipse = [
    {
      type: 'frontmost_application_if',
      bundle_identifiers: ['^org\\.eclipse\\.platform\\.ide$'],
    },
    unlessParallels,
  ]
  var ifAnsiOrIso = [
    { type: 'keyboard_type_if', keyboard_types: ['ansi', 'iso'] },
    unlessParallels,
  ]
  var ifJis = [{ type: 'keyboard_type_if', keyboard_types: ['jis'] }, unlessParallels]

  // to のイベント 1 つぶん。
  function key(keyCode, modifiers) {
    var e = { key_code: keyCode }
    if (modifiers) {
      e.modifiers = modifiers
    }
    return e
  }

  // conditions を省略すると無条件の manipulator になる。
  function map(keyCode, mandatory, optional, to, conditions) {
    var m = {
      type: 'basic',
      from: {
        key_code: keyCode,
        modifiers: { mandatory: mandatory, optional: optional },
      },
      to: to,
    }
    if (conditions) {
      m.conditions = conditions
    }
    return m
  }

  var CONTROL = ['control']
  var OPTION = ['option']

  var manipulators = [
    //
    // Bash style Emacs key bindings (rev 2)
    //
    // control+w: 直前の 1 語を消す
    map('w', CONTROL, ['caps_lock'], [key('delete_or_backspace', ['left_option'])], unlessExcluded),
    // control+u: 行頭まで消す
    map('u', CONTROL, ['caps_lock'], [
      key('left_arrow', ['left_command', 'left_shift']),
      { key_code: 'delete_or_backspace', repeat: false },
    ], unlessExcluded),

    //
    // Emacs key bindings [option+keys] (rev 5)
    //
    map('v', OPTION, ['caps_lock', 'shift'], [key('page_up')], unlessExcluded),
    map('b', OPTION, ['caps_lock', 'shift'], [key('left_arrow', ['left_option'])], unlessExcluded),
    map('f', OPTION, ['caps_lock', 'shift'], [key('right_arrow', ['left_option'])], unlessExcluded),
    map('d', OPTION, ['caps_lock'], [key('delete_forward', ['left_option'])], unlessExcluded),

    //
    // Emacs key bindings [control+keys] (rev 11)
    //
    map('d', CONTROL, ['caps_lock', 'option'], [key('delete_forward')], unlessExcluded),
    map('h', CONTROL, ['caps_lock', 'option'], [key('delete_or_backspace')], unlessExcluded),
    map('i', CONTROL, ['caps_lock', 'shift'], [key('tab')], unlessExcluded),
    // control+[ を Escape に。JIS では ] が同じ位置に来る。
    map('open_bracket', CONTROL, ['caps_lock'], [key('escape')], ifAnsiOrIso),
    map('close_bracket', CONTROL, ['caps_lock'], [key('escape')], ifJis),
    // control+m は除外アプリでも効かせる (端末では ctrl+M が元々 CR なので
    // 変換しても実害が無い、という上流の設計)。Parallels だけは VM 側へ
    // そのまま渡したいので外す。
    map('m', CONTROL, ['caps_lock', 'shift', 'option'], [key('return_or_enter')], [unlessParallels]),
    map('b', CONTROL, ['caps_lock', 'shift', 'option'], [key('left_arrow')], unlessExcluded),
    map('f', CONTROL, ['caps_lock', 'shift', 'option'], [key('right_arrow')], unlessExcluded),
    map('n', CONTROL, ['caps_lock', 'shift', 'option'], [key('down_arrow')], unlessExcluded),
    map('p', CONTROL, ['caps_lock', 'shift', 'option'], [key('up_arrow')], unlessExcluded),
    map('v', CONTROL, ['caps_lock', 'shift'], [key('page_down')], unlessExcluded),
    // 以下は Office / Eclipse でだけ補う。
    map('a', CONTROL, ['caps_lock', 'shift'], [key('home')], ifMsOffice),
    map('e', CONTROL, ['caps_lock', 'shift'], [key('end')], ifMsOffice),
    map('k', CONTROL, ['caps_lock', 'shift'], [
      key('end', ['left_shift']),
      key('delete_forward'),
    ], ifMsOffice),
    map('a', CONTROL, ['caps_lock', 'shift'], [key('left_arrow', ['left_command'])], ifEclipse),
    map('e', CONTROL, ['caps_lock', 'shift'], [key('right_arrow', ['left_command'])], ifEclipse),
  ]

  return {
    description: '[delphinus] Emacs key bindings (control / option / bash style)',
    manipulators: manipulators,
  }
}

main()
