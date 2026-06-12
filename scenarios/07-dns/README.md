# 07-dns: ラボ内 DNS(static-host-mapping + DNS フォワーディング)

r1 をラボの DNS サーバにする。名前は r1 の static-host-mapping(/etc/hosts 相当)を
DNS フォワーディングサービスがそのまま返す。r3 は自前のレコードを持たない
フォワーダで、LAN-B からの問い合わせをすべて r1 へ転送する
(client2 → r3 → r1 という解決の連鎖が観察できる)。

クライアントは 01-lan と同じ静的 IP に戻し、/etc/resolv.conf を各 LAN のルータへ向ける。

| 名前 | アドレス |
|---|---|
| client1.lab | 192.168.10.100 |
| client2.lab | 192.168.20.100 |
| r1.lab | 192.168.10.1 |
| r2.lab | 10.0.12.2 |
| r3.lab | 192.168.20.1 |

## 確認

```
make ssh-client1
  nslookup client2.lab           # 192.168.20.100 が返ること
  ping client2.lab               # 名前で疎通できること
  tcpdump -ni eth1 port 53       # 別端末から nslookup して問い合わせ/応答を観察
make ssh-client2
  nslookup client1.lab           # フォワーダ(r3)経由でも解決できること
make ssh-r2
  sudo tcpdump -ni eth1 port 53  # client2 の問い合わせが r3 → r1 へ転送される様子
```

2 回目の nslookup では r3 がキャッシュから即答するため、r2 にパケットが
流れないことも確認するとよい。

## 発展課題

- r1 にレコードを追加して引けることを確認する
  (`set system static-host-mapping host-name web.lab inet 192.168.10.50`)
- `nslookup 192.168.20.100` で逆引き(PTR)を試す
- r1 の DNS を止め(`delete service dns forwarding`)、
  「名前は引けないが IP では疎通する」状態を体験する → 戻す
