#!/bin/bash
# secrets.yml (1Password document) を扱う共通処理。bin/play-ansbile と
# bin/edit-secrets が source する。単体では実行しない。
#
# ansible/vars/secrets.yml は git 管理外で、1Password (my.1password.com の
# Private vault) が単一の真実。平文も暗号文もコミットしない方針は維持したまま、
# 内容の SHA256 だけを ansible/vars/secrets.yml.sha256 としてコミットする。
#
# これが無いと secrets.yml の変更が git 差分に一切現れず、daily-sync が
# 「play-ansbile を流し直す必要がある」を検出できない (特に別の端末で編集した
# 場合、その端末以外は永久に気付けない)。ハッシュを git で運ぶことで、pull した
# 端末が ^ansible/ の差分として拾えるようになる。
#
# ファイル全体のハッシュなので、公開されても漏れるのは「いつ変わったか」だけ。
# 中身は多数のトークンを含む高エントロピーなデータなので復元はできない。

SECRETS_DOC='ansible/vars/secrets.yml'
SECRETS_ACCOUNT='my.1password.com'
SECRETS_VAULT='Private'
# document 内のファイル名。op document edit は渡したパスの名前で上書きするので、
# 一時ファイルから書き戻しても名前が変わらないよう明示する。
SECRETS_FILE_NAME='secrets.yml'

# 1Password から取り出して $1 に置く。
fetch_secrets() {
    op document get "$SECRETS_DOC" \
        --account "$SECRETS_ACCOUNT" --vault "$SECRETS_VAULT" >"$1"
}

# $1 の内容で 1Password の document を置き換える。
put_secrets() {
    op document edit "$SECRETS_DOC" "$1" \
        --account "$SECRETS_ACCOUNT" --vault "$SECRETS_VAULT" \
        --file-name "$SECRETS_FILE_NAME"
}

# 取得・編集した内容が壊れていないか検証する。
#
# op が不調なときに部分的な内容を返すことがあり (実測: 2 回連続で別々の位置で
# 切れ、`'secret_office' is undefined` 等でプレイブックが中断した)、その場合でも
# exit code は 0 で、YAML としては読めてしまう。ファイル全体に散らばる番兵キーの
# 存在で切り詰めを検出する。編集後にも掛けることで、壊した YAML を 1Password に
# push してしまう事故も防ぐ。
validate_secrets() {
    python3 - "$1" <<'PY'
import sys, yaml

path = sys.argv[1]
with open(path) as fh:
    body = fh.read()
if len(body) < 10000:
    sys.exit(f'secrets.yml が小さすぎる ({len(body)} バイト)。取得が不完全な可能性がある')
try:
    doc = yaml.safe_load(body)
except yaml.YAMLError as e:
    sys.exit(f'secrets.yml が YAML として壊れている: {e}')

# ファイルの先頭・中間・末尾に散らばるキーを選んである。
sentinels = ['ansible_become_pass', 'secret_office', 'secret_aws_vault_op_vault_id',
             'secret_zshrc_local', 'secret_config_files']
missing = [k for k in sentinels if k not in doc]
if missing:
    sys.exit(f'secrets.yml の取得が不完全 (欠けているキー: {", ".join(missing)})。'
             '1Password の状態を確認して再実行する')
print(f'secrets.yml 検証 OK ({len(body)} バイト, {len(doc)} キー)')
PY
}

# 内容のハッシュを ansible/vars/secrets.yml.sha256 に記録する。
#
# 必ず validate_secrets を通した後に呼ぶこと。切り詰められた内容のハッシュを
# コミットして配ると、全端末が偽の「変更あり」を掴む。
update_secrets_hash() {
    local src="$1" dotfiles hash_file rel new old
    dotfiles="${DOTFILES_DIR:-$HOME/git/dotfiles}"
    rel='ansible/vars/secrets.yml.sha256'
    hash_file="$dotfiles/$rel"
    new="$(shasum -a 256 "$src" | cut -d' ' -f1)"
    old="$(cat "$hash_file" 2>/dev/null || true)"
    if [[ "$new" == "$old" ]]; then
        echo "secrets.yml のハッシュに変化なし"
        return 0
    fi
    printf '%s\n' "$new" >"$hash_file"
    echo "secrets.yml のハッシュを更新した: ${old:-(記録なし)} -> $new"
    echo "他の端末に伝えるためコミットしてください:"
    echo "  git -C $dotfiles add $rel && git -C $dotfiles commit -m 'ansible: secrets.yml を更新'"
}
