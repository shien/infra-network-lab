#!/usr/bin/env bash
# VM 5 台を作成・起動する(冪等)。
# ベースイメージ + 差分 qcow2、cloud-init seed ISO、virt-install --import の組み合わせ。
source "$(dirname "$0")/lib.sh"

[ -f "$VYOS_BASE" ]   || die "VyOS ベースイメージがありません。先に: make images"
[ -f "$ALPINE_BASE" ] || die "Alpine イメージがありません。先に: make images"

mkdir -p "$BUILD_DIR" "$(dirname "$KEY_FILE")"
if [ ! -f "$KEY_FILE" ]; then
  ssh-keygen -q -t ed25519 -N '' -C lab -f "$KEY_FILE"
  log "ラボ用 SSH 鍵を生成しました: $KEY_FILE"
fi
read -r KEY_TYPE KEY_B64 _ < "$KEY_FILE.pub"
PUBKEY="$KEY_TYPE $KEY_B64 lab"

for vm in $VMS; do
  dom="$LAB_VM_PREFIX$vm"
  if virsh dominfo "$dom" >/dev/null 2>&1; then
    log "$dom: 定義済み(スキップ)"
    continue
  fi

  kind="$(vm_kind "$vm")"
  if [ "$kind" = router ]; then base="$VYOS_BASE"; else base="$ALPINE_BASE"; fi
  disk="$REPO_ROOT/$BUILD_DIR/$vm.qcow2"
  seed="$REPO_ROOT/$BUILD_DIR/$vm-seed.iso"
  ci="$BUILD_DIR/cloud-init-rendered/$vm"
  mkdir -p "$ci"

  qemu-img create -q -f qcow2 -b "$(realpath "$base")" -F qcow2 "$disk"

  # テンプレートの鍵プレースホルダを実鍵に置換して seed ISO を作る
  sed -e "s|@SSH_PUBKEY@|$PUBKEY|" \
      -e "s|@SSH_KEY_TYPE@|$KEY_TYPE|" \
      -e "s|@SSH_KEY_B64@|$KEY_B64|" \
      "cloud-init/$vm/user-data" > "$ci/user-data"
  printf 'instance-id: %s\nlocal-hostname: %s\n' "$dom" "$vm" > "$ci/meta-data"
  if [ -f "cloud-init/$vm/network-config" ]; then
    cloud-localds --network-config="cloud-init/$vm/network-config" \
      "$seed" "$ci/user-data" "$ci/meta-data"
  else
    cloud-localds "$seed" "$ci/user-data" "$ci/meta-data"
  fi

  netargs=()
  for n in $(vm_nets "$vm"); do
    netargs+=(--network "network=$n,model=virtio")
  done

  virt-install \
    --name "$dom" \
    --memory "$(vm_ram "$vm")" \
    --vcpus "$VCPUS" \
    --import \
    --disk "path=$disk,format=qcow2,bus=virtio" \
    --disk "path=$seed,device=cdrom" \
    --osinfo detect=on,require=off \
    "${netargs[@]}" \
    --graphics none \
    --console pty,target_type=serial \
    --noautoconsole >/dev/null
  log "$dom: 作成・起動しました"
done

wait_ssh_all
log "全 VM が起動し SSH 可能になりました(make status で一覧表示)"
