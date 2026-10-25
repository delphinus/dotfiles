# Homebrew の vendor_conf.d/direnv.fish と同じ名前にして、そちらを読ませない
# (fish は conf.d に同名のファイルがあると vendor_conf.d の方を飛ばす)。
# 中身は同じ `direnv hook fish | source` を、毎回 direnv を起動せずに済むよう
# キャッシュしたもの。
status is-interactive; or exit 0
type -q direnv; or exit 0
__source_cached direnv (type -P direnv) -- direnv hook fish
