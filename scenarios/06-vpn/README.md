# 06-vpn: WireGuard site-to-site VPN

r2 を「LAN を知らないインターネット」に見立て(LAN への経路なし)、
r1–r3 間に WireGuard トンネル(10.99.0.0/30)を張って LAN 同士を再疎通させる。
鍵ペアは apply.sh が各ルータ上で生成するため、リポジトリには含まれない。

## 確認

```
make ssh-r1
  show interfaces wireguard wg0  # ピアと latest handshake を確認
  ping 10.99.0.2                 # トンネル対向
make ssh-client1
  ping 192.168.20.100            # LAN 間はトンネル経由で疎通
  traceroute 192.168.20.100      # ホップが r1 -> (wg0) -> r3 になり r2 が見えないこと
make ssh-r2
  show ip route                  # LAN への経路が無いこと
  sudo tcpdump -ni eth1 udp port 51820   # 暗号化された WireGuard パケットのみ見えること
```

## 発展課題

- r2 の tcpdump で平文(192.168.x.x)が見えないことを確認する
- IPsec(IKEv2)版の site-to-site を自分で設定してみる(`set vpn ipsec ...`)
