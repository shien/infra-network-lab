#!/usr/bin/env bash
# 共通関数・共通設定。各スクリプトの先頭で source される。
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
# shellcheck disable=SC1091
source "$REPO_ROOT/lab.conf"

# libvirt はシステム接続を使う(virsh / virt-install 共通)
export LIBVIRT_DEFAULT_URI=qemu:///system

SSH_OPTS=(-i "$KEY_FILE"
  -o StrictHostKeyChecking=no
  -o UserKnownHostsFile=/dev/null
  -o LogLevel=ERROR
  -o ConnectTimeout=5)

log() { echo "[lab] $*"; }
die() { echo "[lab] ERROR: $*" >&2; exit 1; }

vm_ip()   { local v="MGMT_IP_$1"; echo "${!v}"; }
vm_nets() { local v="NETS_$1";    echo "${!v}"; }
vm_kind() { case "$1" in r*) echo router ;; *) echo client ;; esac; }
vm_user() { if [ "$(vm_kind "$1")" = router ]; then echo vyos; else echo root; fi; }
vm_ram()  { local v="RAM_$(vm_kind "$1")"; echo "${!v}"; }

vm_ssh() {  # vm_ssh <vm> [コマンド...]
  local vm="$1"; shift
  ssh "${SSH_OPTS[@]}" "$(vm_user "$vm")@$(vm_ip "$vm")" "$@"
}

wait_ssh_all() {  # 全 VM へ SSH 可能になるまで待つ(最大 10 分)
  local vm deadline=$(( $(date +%s) + 600 ))
  for vm in $VMS; do
    log "SSH 待機: $vm ($(vm_ip "$vm")) ..."
    until vm_ssh "$vm" true 2>/dev/null; do
      if [ "$(date +%s)" -ge "$deadline" ]; then
        die "$vm への SSH がタイムアウトしました(virsh console $LAB_VM_PREFIX$vm で状態を確認してください)"
      fi
      sleep 5
    done
    log "  -> OK"
  done
}

# シナリオ適用時に必ず初期化する設定ツリー。
# 管理用の eth0 と SSH には触れないため、適用中に接続は失われない。
VYOS_RESET_CMDS='
delete interfaces ethernet eth1 address
delete interfaces ethernet eth1 description
delete interfaces ethernet eth2 address
delete interfaces ethernet eth2 description
delete interfaces loopback lo address
delete interfaces wireguard
delete protocols
delete service dhcp-server
delete firewall
delete nat
delete vpn
'

vyos_apply() {  # vyos_apply <vm> [cfgファイル...] : リセット後に set コマンド列を投入して commit/save
  local vm="$1"; shift
  {
    echo 'source /opt/vyatta/etc/functions/script-template'
    echo 'configure'
    echo "$VYOS_RESET_CMDS"
    if [ "$#" -gt 0 ]; then
      grep -hvE '^[[:space:]]*(#|$)' "$@" || true
    fi
    echo 'commit'
    echo 'save'
    echo 'exit'
  } | vm_ssh "$vm" vbash -s
}

client_run() {  # client_run <vm> <ローカルの sh スクリプト> : クライアント上で実行
  vm_ssh "$1" sh -s < "$2"
}
