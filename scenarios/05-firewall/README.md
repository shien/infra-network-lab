# 05-firewall: ステートフルファイアウォール

04-bgp の経路を維持したまま、r1 の forward チェインに
「LAN-A → WAN 許可 / WAN → LAN-A は戻り(established/related)と ICMP のみ」
のルールを入れる。

## 確認

```
make ssh-client1
  iperf3 -c 192.168.20.100     # LAN-A 発の新規接続は通る
  ping 192.168.20.100          # ICMP も通る
make ssh-client2
  ping 192.168.10.100          # ICMP は WAN 側からも通る(rule 30)
  iperf3 -c 192.168.10.100     # WAN 側からの新規 TCP は default-action drop で失敗する
make ssh-r1
  show firewall                # ルールごとのカウンタを確認
  show log firewall            # drop/accept のログを確認
```

## 発展課題

- rule 30(ICMP 許可)を消して ping が落ちることを確認する
- 特定ポート(tcp/5201)だけ WAN → LAN を許可するルールを追加する
