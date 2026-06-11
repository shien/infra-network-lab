# 01-lan: シンプルな LAN と静的ルーティング

IP アドレスの手設定と静的経路だけで client1 ⇔ client2 を疎通させる。

## 確認

```
make ssh-client1
  ping 192.168.10.1          # 同一セグメント(r1)
  ping 192.168.20.100        # 対向クライアント
  traceroute 192.168.20.100  # r1 -> r2 -> r3 を通ること
make ssh-r1
  show ip route              # S(static) と C(connected) の経路を確認
```
