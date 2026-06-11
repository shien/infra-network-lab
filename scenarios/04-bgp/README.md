# 04-bgp: 3 AS 構成の eBGP

r1(AS65001)/ r3(AS65002)が自 LAN を広告し、r2(AS65000)が
ISP/トランジットとして経路を中継する。

## 確認

```
make ssh-r2
  show ip bgp summary          # 2 ピアが Established であること
  show ip bgp                  # 両 LAN の経路と AS パスを確認
make ssh-r1
  show ip bgp                  # 192.168.20.0/24 の AS パスが 65000 65002 であること
make ssh-client1
  ping 192.168.20.100
```

## 発展課題

- r2 で prefix-list / route-map を使い、特定経路の広告をフィルタする
- r1 で `show ip bgp neighbors 10.0.12.2 advertised-routes` を確認する
