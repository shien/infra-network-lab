# VyOS × KVM ネットワーク演習ラボ 計画書

Ubuntu ホスト上の KVM/libvirt に、VyOS ルータ 3 台と軽量クライアント 2 台からなる
ネットワーク演習環境を**最小構成・コマンド一発で自動構築**するための計画ドキュメント集です。

## 演習で扱うテーマ

- シンプルな LAN(疎通・静的ルーティングの基礎)
- DHCP(VyOS による DHCP サーバ)
- OSPF(ルータ 3 台での動的ルーティング)
- BGP(3 AS 構成の eBGP)
- Firewall(VyOS のゾーンベースファイアウォール)
- VPN(WireGuard / IPsec による site-to-site VPN)

## 基本方針

- **最小構成**: 全演習を VM 5 台(VyOS ルータ 3 台 + Alpine クライアント 2 台)、
  合計 約 5 vCPU / 3.5 GB RAM でカバーする
- **トポロジは固定**: 物理(仮想)配線は一切変えず、演習ごとに VyOS の設定だけを差し替える
- **無償で完結**: VyOS は無償の rolling(nightly)ビルド、クライアントは Alpine Linux を使用
- **依存最小の自動化**: bash + Makefile + virt-install + cloud-init のみで構築。
  Terraform / Vagrant 等の追加ツールは導入しない

## ドキュメント構成

| ファイル | 内容 |
|---|---|
| [01-requirements.md](01-requirements.md) | ホストマシン要件・VM スペック・リソース合計 |
| [02-architecture.md](02-architecture.md) | トポロジ図・libvirt ネットワーク設計・IP アドレス計画 |
| [03-software.md](03-software.md) | 使用ソフトウェア一覧・イメージの入手方法 |
| [04-automation.md](04-automation.md) | 自動構築の仕組み(ディレクトリ構成・ライフサイクル) |
| [05-exercises.md](05-exercises.md) | 演習シナリオ一覧と各演習の目標・確認方法 |
