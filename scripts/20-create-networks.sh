#!/usr/bin/env bash
# libvirt 仮想ネットワーク(labnet-*)を定義・起動する(冪等)
source "$(dirname "$0")/lib.sh"

for xml in networks/*.xml; do
  name="$(basename "$xml" .xml)"
  if ! virsh net-info "$name" >/dev/null 2>&1; then
    virsh net-define "$xml" >/dev/null
    log "$name: 定義しました"
  fi
  if [ "$(virsh net-info "$name" | awk '/^Active/ {print $2}')" != "yes" ]; then
    virsh net-start "$name" >/dev/null
    log "$name: 起動しました"
  else
    log "$name: 起動済み"
  fi
done
