# 02-dhcp: eth1 を DHCP クライアント(udhcpc)に切り替える
pkill udhcpc 2>/dev/null || true
ip route del default 2>/dev/null || true
ip addr flush dev eth1
ip link set eth1 up
udhcpc -i eth1 -b -t 10
sleep 2
echo "--- client1 eth1 (DHCP) ---"
ip -br addr show eth1
ip route show
