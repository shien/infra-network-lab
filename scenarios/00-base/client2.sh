# 00-base: eth1 を初期状態(静的 192.168.20.100/24、デフォルト経路なし)へ戻す
pkill udhcpc 2>/dev/null || true
ip route del default 2>/dev/null || true
ip addr flush dev eth1
ip addr add 192.168.20.100/24 dev eth1
ip link set eth1 up
echo "--- client2 eth1 ---"
ip -br addr show eth1
