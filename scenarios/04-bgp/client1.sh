# 04-bgp: クライアントは DHCP のまま
pkill udhcpc 2>/dev/null || true
ip route del default 2>/dev/null || true
ip addr flush dev eth1
ip link set eth1 up
udhcpc -i eth1 -b -t 10
sleep 2
ip -br addr show eth1
