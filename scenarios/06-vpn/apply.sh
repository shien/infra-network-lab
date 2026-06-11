#!/usr/bin/env bash
# 06-vpn: WireGuard 鍵ペアを各ルータ上で生成し、cfg のプレースホルダを
# 置換してから適用する(鍵はリポジトリに置かず毎回生成する)
source "$(dirname "${BASH_SOURCE[0]}")/../../scripts/lib.sh"
dir="scenarios/06-vpn"

log "WireGuard 鍵ペアを生成します (r1, r3)"
r1_priv=$(vm_ssh r1 wg genkey)
r3_priv=$(vm_ssh r3 wg genkey)
r1_pub=$(echo "$r1_priv" | vm_ssh r1 wg pubkey)
r3_pub=$(echo "$r3_priv" | vm_ssh r3 wg pubkey)

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
sed -e "s|@WG_PRIV@|$r1_priv|" -e "s|@WG_PEER_PUB@|$r3_pub|" "$dir/r1.cfg" > "$tmp/r1.cfg"
sed -e "s|@WG_PRIV@|$r3_priv|" -e "s|@WG_PEER_PUB@|$r1_pub|" "$dir/r3.cfg" > "$tmp/r3.cfg"

log "r1: 適用(トンネル終端)"
vyos_apply r1 "$tmp/r1.cfg"
log "r2: 適用(LAN への経路を持たないインターネット役)"
vyos_apply r2 "$dir/r2.cfg"
log "r3: 適用(トンネル終端)"
vyos_apply r3 "$tmp/r3.cfg"
