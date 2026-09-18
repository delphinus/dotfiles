// [delphinus] 画面共有.app でファンクションキーを入れ替える
//
// 画面共有の先にある Mac へ F1〜F12 をそのまま送りたい。macOS の
// 「F1、F2 などのキーを標準のファンクションキーとして使用」が無効のときは、
// F1 を押しても手元の輝度が変わるだけで、向こうには届かない。
//
// Karabiner でキーを送るときの決まりごと (公式ドキュメント
// https://karabiner-elements.pqrs.org/docs/help/how-to/function-keys/):
// complex modification で f1 を出しても、後段の Function Keys Modifications と
// macOS のドライバがそれを輝度などのメディアキーとして解釈する。F1 そのものを
// アプリへ届けたいときは fn+F1 を出す。
//
// そこで画面共有が最前面のあいだだけ fn の有無を入れ替える:
//
//   F1      → fn+F1 → 向こうの Mac へ F1 が届く
//   fn+F1   → F1    → 手元の輝度・音量などが動く
//
// 「標準のファンクションキーとして使用」が有効な端末では F1 がそのまま F1 に
// なるので、変換すると逆に困る。system.use_fkeys_as_standard_function_keys で
// 判定し、その場合は何もしない (この変数は Karabiner 15.2.3 以降)。
//
// 必要バージョン: assets へ .js を置いて読ませるには 16.2.0 以降。
// ECMAScript 5.1 (Duktape) のみ。require() は使えないので単体で完結させる。
// 検証: karabiner_cli --lint-complex-modifications screensharing.js

function main() {
  var CONDITIONS = [
    {
      type: 'frontmost_application_if',
      bundle_identifiers: ['^com\\.apple\\.ScreenSharing$'],
    },
    {
      type: 'variable_unless',
      name: 'system.use_fkeys_as_standard_function_keys',
      value: true,
    },
  ]

  var manipulators = []

  for (var i = 1; i <= 12; ++i) {
    var fkey = 'f' + i

    // fn を押しているときは手元のメディアキーとして扱う。fn 無しの方が
    // optional: any で fn も拾ってしまうので、必ずこちらを先に置く。
    manipulators.push({
      type: 'basic',
      from: { key_code: fkey, modifiers: { mandatory: ['fn'], optional: ['any'] } },
      to: [{ key_code: fkey }],
      conditions: CONDITIONS,
    })

    manipulators.push({
      type: 'basic',
      from: { key_code: fkey, modifiers: { optional: ['any'] } },
      to: [{ key_code: fkey, modifiers: ['fn'] }],
      conditions: CONDITIONS,
    })
  }

  return {
    description: '[delphinus] 画面共有.app では F1〜F12 を fn 付きで送る',
    manipulators: manipulators,
  }
}

main()
