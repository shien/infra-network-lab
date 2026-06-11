#!/usr/bin/env bash
# 指定 VM へ SSH ログインする: scripts/ssh.sh r1
source "$(dirname "$0")/lib.sh"

vm="${1:?usage: $0 <vm>  (r1 r2 r3 client1 client2)}"
case " $VMS " in
  *" $vm "*) ;;
  *) die "不明な VM: $vm(指定可能: $VMS)" ;;
esac
exec ssh "${SSH_OPTS[@]}" "$(vm_user "$vm")@$(vm_ip "$vm")"
