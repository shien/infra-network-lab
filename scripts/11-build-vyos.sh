#!/usr/bin/env bash
# VyOS ISO から cloud-init(NoCloud)対応の qcow2 ベースイメージをビルドする(初回のみ)。
# 公式ツール vyos/vyos-vm-images の Ansible playbook を Docker コンテナ内で実行する。
# オプションの詳細: https://github.com/vyos/vyos-vm-images
source "$(dirname "$0")/lib.sh"

if [ -f "$VYOS_BASE" ]; then
  log "VyOS ベースイメージ: ビルド済み ($VYOS_BASE)"
  exit 0
fi
[ -f "$VYOS_ISO" ] || die "ISO がありません。先に scripts/10-fetch-images.sh を実行してください"
command -v git >/dev/null || die "git が必要です"
command -v docker >/dev/null \
  || die "docker が必要です(このビルドでのみ使用): sudo apt install -y docker.io"

DOCKER=docker
docker info >/dev/null 2>&1 || DOCKER="sudo docker"

workdir="$IMAGES_DIR/vyos-vm-images"
[ -d "$workdir" ] || git clone https://github.com/vyos/vyos-vm-images.git "$workdir"

$DOCKER build -t vyos-vm-images "$workdir"
$DOCKER run --rm --privileged \
  -v "$REPO_ROOT/$workdir:/vm-build" \
  -v "$REPO_ROOT/$IMAGES_DIR:/images" \
  -w /vm-build \
  vyos-vm-images \
  ansible-playbook qemu.yml \
    -e iso_local="/images/$(basename "$VYOS_ISO")" \
    -e disk_size="$VYOS_DISK_GB" \
    -e grub_console=serial \
    -e cloud_init=true \
    -e cloud_init_ds=NoCloud

# playbook が出力した qcow2(ISO より新しいもの)をベースイメージ名へ移動する
out=$(find "$IMAGES_DIR" "$workdir" -maxdepth 1 -name 'vyos*.qcow2' \
        ! -name "$(basename "$VYOS_BASE")" -newer "$VYOS_ISO" \
        -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2- || true)
[ -n "$out" ] || die "ビルド成果物の qcow2 が見つかりません。vyos-vm-images の出力と README を確認してください"
mv "$out" "$VYOS_BASE"
log "完了: $VYOS_BASE"
