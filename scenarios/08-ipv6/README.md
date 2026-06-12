# 08-ipv6: デュアルスタック(SLAAC + OSPFv3)

01-lan の IPv4 構成はそのままに、全リンクへ IPv6 を重ねる。
LAN のクライアントは r1/r3 のルータ広告(RA)による SLAAC で自動設定され、
ルータ間は OSPFv3 で IPv6 経路を交換する。クライアントの IPv4 設定は変わらない
(= デュアルスタック)。

| セグメント | IPv6 プレフィックス |
|---|---|
| LAN-A | 2001:db8:a::/64(r1 = ::1) |
| LAN-B | 2001:db8:b::/64(r3 = ::1) |
| r1–r2 | 2001:db8:12::/64 |
| r2–r3 | 2001:db8:23::/64 |

クライアントの IPv6 アドレスは SLAAC が生成するため固定ではない。
対向クライアントへ ping したいときは `ip -6 addr` で相手のアドレスを調べる。

## 確認

```
make ssh-client1
  ip -6 addr show eth1           # 2001:db8:a: で始まるアドレス(SLAAC)+ fe80::(リンクローカル)
  ip -6 route                    # default via fe80::...(RA から学習)
  ping -6 2001:db8:b::1          # LAN-B 側の r3 まで IPv6 で到達
  ip -6 neigh                    # NDP テーブル(ARP テーブルの IPv6 版)
make ssh-r2
  show ipv6 ospfv3 neighbor      # r1 / r3 と隣接
  show ipv6 route ospfv3         # 両 LAN のプレフィックスを OSPFv3 で学習
```

RS/RA・NS/NA の観察: client1 で `tcpdump -ni eth1 icmp6` を流したまま、
別端末から `ip link set eth1 down && ip link set eth1 up` すると
RS → RA → DAD(NS)の流れが見える。

## 発展課題

- client1 ↔ client2 を SLAAC アドレス同士で ping -6 / traceroute6 する
- r1 の RA を止め(`delete service router-advert`)、クライアントのアドレスと
  デフォルト経路がどうなるか(lifetime 切れ)を観察する → 戻す
- `show ipv6 ospfv3 database` を IPv4 OSPF(03-ospf)の LSDB と見比べる
