# infra-network-lab

Ubuntu 上の KVM/libvirt に VyOS ルータ 3 台 + 軽量クライアント(Alpine)2 台の
ネットワーク演習環境を自動構築するプロジェクト。

DHCP / OSPF / BGP / シンプルな LAN / VPN / firewall の演習を、
固定トポロジ(VM 5 台・約 3.5 GB RAM)の設定差し替えだけで行える。

```
 client1 ── [lan-a] ── r1 ──[wan-a]── r2 ──[wan-b]── r3 ── [lan-b] ── client2
 192.168.10.0/24        10.0.12.0/30    10.0.23.0/30       192.168.20.0/24
                    AS65001       AS65000(ISP役)      AS65002

 mgmt: 172.16.99.0/24(libvirt NAT)— 全 VM の eth0。SSH/設定投入用
```

## 使い方

```sh
make prereqs            # ホスト要件チェック(導入: scripts/00-prereqs.sh --install)
make images             # イメージ取得 + VyOS ベースイメージのビルド(初回のみ。docker が必要)
make up                 # ネットワーク + VM 5 台を作成・起動(ベースライン設定)
make scenario-01-lan    # 演習シナリオを適用(01-lan / 02-dhcp / 03-ospf / 04-bgp / 05-firewall / 06-vpn)
make status             # 状態と SSH 先の一覧
make ssh-r1             # 各 VM へ SSH(r1 r2 r3 client1 client2)
make reset              # 全ルータをベースラインへ戻す
make down               # VM・ネットワークを削除(イメージは残す)
```

- 各演習の目標・確認コマンドは `scenarios/<名前>/README.md`(適用時にも表示される)
- ルータへはラボ専用鍵で `vyos` ユーザ、クライアントへは `root` でログインする
  (コンソールは `virsh -c qemu:///system console lab-r1`、vyos/vyos)
- 演習設定を壊しても `make reset`、それでも駄目なら `make down && make up`

## ドキュメント

設計の詳細(スペック・IP 計画・ソフトウェア選定・自動化設計・演習一覧)は
[plan/](plan/) を参照。

| ドキュメント | 内容 |
|---|---|
| [plan/01-requirements.md](plan/01-requirements.md) | ホスト要件・VM スペック |
| [plan/02-architecture.md](plan/02-architecture.md) | トポロジ・IP アドレス計画 |
| [plan/03-software.md](plan/03-software.md) | 使用ソフトウェア・イメージ入手方法 |
| [plan/04-automation.md](plan/04-automation.md) | 自動構築の仕組み |
| [plan/05-exercises.md](plan/05-exercises.md) | 演習シナリオ一覧 |

## リポジトリ構成

```
Makefile             操作の入口(up / down / scenario-* / ssh-* など)
lab.conf             共通変数(IP・スペック・イメージパス)
networks/            libvirt ネットワーク定義 XML(labnet-*)
cloud-init/          VM ごとの初期設定テンプレート(NoCloud)
scenarios/           演習ごとの VyOS 設定とクライアント操作
scripts/             構築・破棄・シナリオ適用スクリプト
plan/                計画ドキュメント
images/ build/ keys/ 生成物(git 管理外)
```
