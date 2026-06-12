# 08-ipv6: IPv4 は静的のまま、IPv6 は RA(SLAAC)で自動取得する
pkill udhcpc 2>/dev/null || true
sysctl -w net.ipv6.conf.eth1.accept_ra=1 >/dev/null
ip addr flush dev eth1
ip addr add 192.168.20.100/24 dev eth1
ip route replace default via 192.168.20.1 dev eth1
# link を上げ直して RS(Router Solicitation)を送らせ、RA を待つ
ip link set eth1 down
ip link set eth1 up
sleep 8
echo "--- client2 eth1 (IPv4 + IPv6) ---"
ip -br addr show eth1
ip -6 route show
