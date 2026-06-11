# 03. 使用ソフトウェア

すべて無償で入手できるものだけで構成する。

## ホスト側(Ubuntu に apt でインストール)

| パッケージ | 用途 |
|---|---|
| qemu-kvm(qemu-system-x86) | ハイパーバイザ |
| libvirt-daemon-system | VM / 仮想ネットワークの管理デーモン |
| libvirt-clients | virsh コマンド |
| virtinst | virt-install(VM 定義の自動作成) |
| qemu-utils | qemu-img(qcow2 の作成・backing file) |
| cloud-image-utils | cloud-localds(cloud-init NoCloud の seed ISO 生成) |
| openssh-client, sshpass(任意) | VM への設定投入・演習操作 |

インストール例:

```sh
sudo apt update
sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients \
  virtinst qemu-utils cloud-image-utils
sudo usermod -aG libvirt "$USER"   # 再ログインが必要
```

## ゲスト OS イメージ

### VyOS 1.5 rolling(ルータ用)

- **入手先**: <https://vyos.net/get/nightly-builds/>(実体は GitHub Releases
  <https://github.com/vyos/vyos-nightly-build/releases> )
- **無償可否**: rolling(nightly)ビルドは無償・登録不要。
  LTS(1.4 sagitta / 1.5 circinus)のバイナリはサブスクリプション契約者向けのため使わない。
  演習用途では rolling で十分
- **形式**: 配布されるのは ISO。自動構築には cloud-init 対応の qcow2 が必要なので、
  公式の **[vyos/vyos-vm-images](https://github.com/vyos/vyos-vm-images)** リポジトリの
  Ansible playbook(Docker コンテナ内で実行可)で ISO から qcow2 を**一度だけ**ビルドする
  - ビルド時オプションで cloud-init(NoCloud データソース)を有効化する
  - 生成した qcow2 をベースイメージとして r1/r2/r3 の差分ディスクを作る
- **設定の自動投入**: cloud-init の user-data に `vyos_config_commands` を書くと
  初回起動時に VyOS の set コマンド列が自動適用される
  (参考: <https://docs.vyos.io/en/latest/automation/cloud-init.html>)

### Alpine Linux(クライアント用)

- **入手先**: <https://alpinelinux.org/cloud/> の cloud イメージ
  (`nocloud` 対応 / `virt` 最適化カーネルの qcow2 を選択)
- **無償可否**: 完全に無償(MIT 等の OSS ライセンス)
- **選定理由**: qcow2 で数百 MB・RAM 256 MB で動作し、cloud-init(NoCloud)で
  ユーザ・SSH 鍵・静的 IP を自動設定できる。演習に必要なツールは apk で追加する
- **演習用に入れるパッケージ**: `iperf3` `tcpdump` `mtr` `curl`
  (DHCP クライアント / ping / traceroute は標準で利用可。
  cloud-init 初回起動時に mgmt 経由でインストールする)

代替案として Ubuntu Minimal Cloud Image も使えるが、RAM 512 MB 以上を要求し
起動も遅いため、軽量さを優先して Alpine を採用する。

## 自動化レイヤ

| ツール | 用途 | 備考 |
|---|---|---|
| bash + Makefile | 構築・破棄・演習切替の入口 | 追加インストール不要 |
| virt-install | VM 定義の作成 | libvirt 標準ツール |
| cloud-init(NoCloud seed ISO) | 初回起動時の自動設定 | VyOS / Alpine 両対応 |
| ssh(+ vbash) | 演習シナリオの設定差し替え | mgmt ネットワーク経由 |

### Terraform / Vagrant / Ansible を採用しない理由

- **Terraform(libvirt provider)**: 宣言的で便利だが、ツール本体 + provider の
  インストールと state 管理が増え「最小構成」に反する
- **Vagrant**: vagrant-libvirt プラグインのメンテナンス状況が不安定で、
  VyOS rolling の box も公式提供がない
- **Ansible(vyos.vyos コレクション)**: シナリオ投入の代替として優秀なので、
  **将来の拡張候補**として設計上の置き換えポイントを残す(04-automation.md 参照)。
  初期実装では依存を増やさないため ssh + 設定スクリプトで行う
