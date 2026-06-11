# 05-firewall: クライアントは DHCP のまま。検証用に iperf3 サーバを起動しておく
pkill udhcpc 2>/dev/null || true
ip route del default 2>/dev/null || true
ip addr flush dev eth1
ip link set eth1 up
udhcpc -i eth1 -b -t 10
sleep 2
pkill iperf3 2>/dev/null || true
iperf3 -s -D
ip -br addr show eth1
echo "iperf3 server: 起動済み(WAN 側からの新規接続が FW で落ちることを確認する)"
