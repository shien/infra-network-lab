#!/usr/bin/env bash
# VM とネットワークを削除する(ダウンロード済みイメージと SSH 鍵は残す)
source "$(dirname "$0")/lib.sh"

for vm in $VMS; do
  dom="$LAB_VM_PREFIX$vm"
  virsh destroy  "$dom" >/dev/null 2>&1 && log "$dom: 停止しました" || true
  virsh undefine "$dom" >/dev/null 2>&1 && log "$dom: 削除しました" || true
done

for xml in networks/*.xml; do
  name="$(basename "$xml" .xml)"
  virsh net-destroy  "$name" >/dev/null 2>&1 && log "$name: 停止しました" || true
  virsh net-undefine "$name" >/dev/null 2>&1 && log "$name: 削除しました" || true
done

rm -rf "$BUILD_DIR"
log "完了(images/ と keys/ は残しています。完全削除は make clean)"
