#!/usr/bin/env bash
# VyOS rolling ISO と Alpine cloud イメージをダウンロードする(取得済みならスキップ)
source "$(dirname "$0")/lib.sh"
mkdir -p "$IMAGES_DIR"

# --- VyOS rolling (nightly) ISO -------------------------------------------
# 無償の nightly ビルド: https://vyos.net/get/nightly-builds/
if [ -f "$VYOS_ISO" ]; then
  log "VyOS ISO: 取得済み ($VYOS_ISO)"
else
  log "VyOS rolling の最新 nightly ビルドを調べています..."
  api="https://api.github.com/repos/vyos/vyos-nightly-build/releases/latest"
  urls=$(curl -fsSL "$api" | grep -o '"browser_download_url": *"[^"]*"' | cut -d'"' -f4) \
    || die "GitHub API に接続できません: $api"
  url=$(echo "$urls" | grep -m1 'generic-amd64\.iso$' || true)
  [ -n "$url" ] || url=$(echo "$urls" | grep -m1 'amd64\.iso$' || true)
  [ -n "$url" ] || die "ISO の URL を特定できませんでした。https://vyos.net/get/nightly-builds/ を確認してください"
  log "ダウンロード: $url"
  curl -fL --progress-bar -o "$VYOS_ISO.part" "$url"
  mv "$VYOS_ISO.part" "$VYOS_ISO"
fi

# --- Alpine cloud イメージ(NoCloud / cloud-init 対応, BIOS 版) -----------
# 一覧: https://alpinelinux.org/cloud/
if [ -f "$ALPINE_BASE" ]; then
  log "Alpine イメージ: 取得済み ($ALPINE_BASE)"
else
  base="https://dl-cdn.alpinelinux.org/alpine/$ALPINE_BRANCH/releases/cloud"
  log "Alpine $ALPINE_BRANCH の cloud イメージを調べています..."
  file=$(curl -fsSL "$base/" \
    | grep -o 'nocloud_alpine-[0-9.]\+-x86_64-bios-cloudinit-r[0-9]\+\.qcow2' \
    | sort -uV | tail -1 || true)
  [ -n "$file" ] || die "イメージ名を特定できませんでした。$base/ と lab.conf の ALPINE_BRANCH を確認してください"
  log "ダウンロード: $base/$file"
  curl -fL --progress-bar -o "$ALPINE_BASE.part" "$base/$file"
  mv "$ALPINE_BASE.part" "$ALPINE_BASE"
fi

log "イメージ取得完了"
