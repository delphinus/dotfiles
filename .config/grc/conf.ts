# prefix_timestamp (ts -i -m '%.s' | ts '%F %T') が行頭に足す
#
#     2026-08-24 10:48:23 0.574100 元の行
#     └─ 時刻 ──────────┘ └ 経過秒 ┘
#
# の 2 つだけを色付けする。本文には触れないので、tail 側で conf.log 等が
# 当たっていればその色がそのまま残る。
#
# 経過秒が 1 秒未満か以上かで色を変える。ログを追っているときに知りたいのは
# 「どこで間が空いたか」なので、1 秒以上だけを目立たせて、あとは沈める。

# 経過秒が 1 秒未満 (0.xxxxxx) — prefix ごと dim
regexp=^(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d) (0\.\d+)
colours=unchanged, dark, dark
count=once
======
# 経過秒が 1 秒以上 — 時刻は dim のまま、経過秒だけ立たせる
regexp=^(\d{4}-\d\d-\d\d \d\d:\d\d:\d\d) ([1-9]\d*\.\d+)
colours=unchanged, dark, bold yellow
count=once
