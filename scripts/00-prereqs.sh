#!/usr/bin/env bash
# ホスト要件の確認と必要パッケージの導入(--install で apt 実行)
source "$(dirname "$0")/lib.sh"

PKGS=(qemu-kvm libvirt-daemon-system libvirt-clients virtinst
      qemu-utils cloud-image-utils curl git openssh-client)

if [ "$(grep -Ec '(vmx|svm)' /proc/cpuinfo)" -eq 0 ]; then
  die "CPU の仮想化支援 (VT-x/AMD-V) が無効です。BIOS/UEFI で有効化してください"
fi
log "仮想化支援: OK"

missing=()
for c in virsh virt-install qemu-img cloud-localds curl git ssh; do
  command -v "$c" >/dev/null || missing+=("$c")
done

if [ "${#missing[@]}" -gt 0 ]; then
  log "不足コマンド: ${missing[*]}"
  if [ "${1:-}" = "--install" ]; then
    sudo apt-get update
    sudo apt-get install -y "${PKGS[@]}"
  else
    log "次のコマンドで導入できます:"
    log "  sudo apt install -y ${PKGS[*]}"
    log "(このスクリプトに --install を付けると自動実行します)"
    exit 1
  fi
fi
log "必要コマンド: OK"

if ! id -nG | grep -qw libvirt; then
  log "注意: $(id -un) が libvirt グループに入っていません:"
  log "  sudo usermod -aG libvirt $(id -un)   # 再ログインが必要"
fi

virsh version >/dev/null || die "libvirt (qemu:///system) に接続できません"
log "libvirt 接続: OK"
log "ホスト要件チェック完了"
