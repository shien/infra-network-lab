# 03-ospf: OSPF による動的ルーティング

静的経路をやめ、ルータ 3 台をエリア 0 のシングルエリア OSPF にする。
loopback(10.255.0.x)をルータ ID に使い、LAN 側は passive にしている。

## 確認

```
make ssh-r2
  show ip ospf neighbor      # r1 / r3 と Full であること
  show ip route ospf         # O の経路で両 LAN が見えること
make ssh-client1
  traceroute 192.168.20.100
```

## 発展課題

- リンク障害時の再収束を観察する(ホスト側で実行):
  `virsh -c qemu:///system domif-setlink lab-r2 vnet<N> down`
  (vnet 名は `virsh domiflist lab-r2` で確認。戻すときは up)
- `set protocols ospf interface eth2 cost 100` でコストを変えて経路を観察する
