# 01-lan: eth1 を静的設定し、デフォルト経路を LAN 側ルータ(r1)へ向ける
pkill udhcpc 2>/dev/null || true
ip addr flush dev eth1
ip addr add 192.168.10.100/24 dev eth1
ip link set eth1 up
ip route replace default via 192.168.10.1 dev eth1
echo "--- client1 eth1 ---"
ip -br addr show eth1
ip route show
