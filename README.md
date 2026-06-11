# infra-network-lab

Ubuntu 上の KVM/libvirt に VyOS ルータ 3 台 + 軽量クライアント(Alpine)2 台の
ネットワーク演習環境を自動構築するプロジェクト。

DHCP / OSPF / BGP / シンプルな LAN / VPN / firewall の演習を、
固定トポロジ(VM 5 台・約 3.5 GB RAM)の設定差し替えだけで行えるようにする。

```
 client1 ── [lan-a] ── r1 ──[wan-a]── r2 ──[wan-b]── r3 ── [lan-b] ── client2
                    AS65001       AS65000(ISP役)      AS65002
```

## ステータス

現在は**計画フェーズ**。必要スペック・構成・使用ソフトウェア・自動化設計は
[plan/](plan/) ディレクトリにまとめている。

| ドキュメント | 内容 |
|---|---|
| [plan/01-requirements.md](plan/01-requirements.md) | ホスト要件・VM スペック |
| [plan/02-architecture.md](plan/02-architecture.md) | トポロジ・IP アドレス計画 |
| [plan/03-software.md](plan/03-software.md) | 使用ソフトウェア・イメージ入手方法 |
| [plan/04-automation.md](plan/04-automation.md) | 自動構築の仕組み(Makefile / スクリプト設計) |
| [plan/05-exercises.md](plan/05-exercises.md) | 演習シナリオ一覧 |

次フェーズで `Makefile` / `scripts/` / `scenarios/` を実装する。
