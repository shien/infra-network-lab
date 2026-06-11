# 02-dhcp: VyOS による DHCP サーバ

r1 / r3 が各 LAN に IP・デフォルト GW を配布し、クライアントは DHCP で
アドレスを取得する(以降のシナリオもクライアントは DHCP のまま)。

## 確認

```
make ssh-r1
  show dhcp server leases        # client1 のリースが見えること
make ssh-client1
  ip addr show eth1              # 192.168.10.100-199 の範囲で取得していること
  ping 192.168.20.100            # DHCP で配られた GW 経由で対向へ届くこと
```

## 発展課題

- リース時間を変えて挙動を観察する(`set service dhcp-server ... lease`)
- client1 の MAC に固定 IP を割り当てる(`... static-mapping`)
