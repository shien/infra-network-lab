#!/usr/bin/env bash
# ラボの状態(適用中シナリオ・VM・ネットワーク・管理 IP)を表示する
source "$(dirname "$0")/lib.sh"

echo "== 適用中シナリオ =="
cat "$BUILD_DIR/current-scenario" 2>/dev/null || echo "(未適用)"
echo
echo "== VM =="
virsh list --all | sed -n "1,2p; /$LAB_VM_PREFIX/p"
echo
echo "== ネットワーク =="
virsh net-list --all | sed -n "1,2p; /labnet-/p"
echo
echo "== 管理 IP / SSH =="
printf '%-10s %-16s %s\n' "VM" "MGMT-IP" "SSH"
for vm in $VMS; do
  printf '%-10s %-16s %s\n' "$vm" "$(vm_ip "$vm")" \
    "ssh -i $KEY_FILE $(vm_user "$vm")@$(vm_ip "$vm")"
done
