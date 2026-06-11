#!/usr/bin/env bash
# 演習シナリオの設定をルータ・クライアントへ投入する: scripts/40-apply-scenario.sh 03-ospf
source "$(dirname "$0")/lib.sh"

scen="${1:?usage: $0 <シナリオ名>  (scenarios/ のディレクトリ名)}"
dir="scenarios/$scen"
[ -d "$dir" ] || die "シナリオがありません: $dir"

if [ -x "$dir/apply.sh" ]; then
  # 事前処理(鍵生成など)が必要なシナリオはルータ側の適用を専用スクリプトに任せる
  log "$scen: 専用の apply.sh を実行します"
  "$dir/apply.sh"
else
  for r in $ROUTERS; do
    if [ -f "$dir/$r.cfg" ]; then
      log "$r: $dir/$r.cfg を適用"
      vyos_apply "$r" "$dir/$r.cfg"
    else
      log "$r: シナリオ設定なし -> ベースラインへリセット"
      vyos_apply "$r"
    fi
  done
fi

for c in $CLIENTS; do
  if [ -f "$dir/$c.sh" ]; then
    log "$c: $dir/$c.sh を実行"
    client_run "$c" "$dir/$c.sh"
  fi
done

mkdir -p "$BUILD_DIR"
echo "$scen" > "$BUILD_DIR/current-scenario"
log "適用完了: $scen"

if [ -f "$dir/README.md" ]; then
  echo
  cat "$dir/README.md"
fi
