# 00-base: ベースライン

全演習の出発点。ルータは mgmt(eth0)と SSH のみ、クライアントは eth1 が
静的 IP(192.168.x.100/24、デフォルト経路なし)の状態になる。

`make reset` はこのシナリオの適用と同じ。演習設定(eth1/eth2 のアドレス、
protocols、dhcp-server、firewall、WireGuard など)はすべて削除される。

## 確認

```
make ssh-r1      # show configuration で演習設定が消えていること
make ssh-client1 # ip addr show eth1 が 192.168.10.100/24 であること
```
