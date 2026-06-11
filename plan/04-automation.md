# 04. 自動構築の仕組み(設計)

`make up` 一発で 5 VM のラボが立ち上がり、`make scenario-03-ospf` のように
演習シナリオを切り替えられる構成を目指す。

## リポジトリの将来ディレクトリ構成

```
infra-network-lab/
├── Makefile                 # 全操作の入口(up / down / status / scenario-*)
├── lab.conf                 # 共通変数(イメージパス・IP・VM スペック)
├── plan/                    # 本計画書(このディレクトリ)
├── images/                  # ダウンロード・ビルドしたイメージ置き場(git 管理外)
│   ├── vyos-base.qcow2      #   VyOS ベースイメージ(vyos-vm-images でビルド)
│   └── alpine-base.qcow2    #   Alpine cloud イメージ
├── networks/                # libvirt ネットワーク定義 XML
│   ├── labnet-mgmt.xml
│   ├── labnet-lan-a.xml ... # 計 5 ファイル
├── cloud-init/              # VM ごとの初期設定(NoCloud user-data / network-config)
│   ├── r1/user-data         #   vyos_config_commands で mgmt IP・SSH を設定
│   ├── r2/user-data
│   ├── r3/user-data
│   ├── client1/{user-data,network-config}
│   └── client2/{user-data,network-config}
├── scenarios/               # 演習ごとの VyOS 設定(set コマンド列)
│   ├── 00-base/             #   ベースライン(mgmt のみ。全演習の出発点)
│   │   ├── r1.cfg  r2.cfg  r3.cfg
│   ├── 01-lan/
│   ├── 02-dhcp/
│   ├── 03-ospf/
│   ├── 04-bgp/
│   ├── 05-firewall/
│   └── 06-vpn/
└── scripts/
    ├── 00-prereqs.sh        # ホストのパッケージ確認・インストール
    ├── 10-fetch-images.sh   # VyOS ISO / Alpine qcow2 のダウンロード
    ├── 11-build-vyos.sh     # vyos-vm-images で ISO → qcow2(初回のみ)
    ├── 20-create-networks.sh
    ├── 30-create-vms.sh     # 差分 qcow2 + seed ISO 生成 + virt-install
    ├── 40-apply-scenario.sh # ssh 経由でシナリオ設定を投入
    ├── 50-destroy.sh        # VM・ネットワーク・差分ディスクの全削除
    └── lib.sh               # 共通関数(IP 定義は lab.conf を参照)
```

## Makefile のターゲット(ライフサイクル)

| ターゲット | 動作 |
|---|---|
| `make prereqs` | ホスト要件チェックと apt パッケージ導入 |
| `make images` | イメージ取得 + VyOS qcow2 ビルド(初回のみ。冪等) |
| `make up` | ネットワーク作成 → VM 作成・起動 → ベースライン設定適用 |
| `make scenario-02-dhcp` 等 | 該当シナリオの設定を r1/r2/r3 に投入(クライアントも必要なら再設定) |
| `make reset` | 全ルータをベースライン(00-base)に戻す |
| `make status` | VM / ネットワークの状態と mgmt IP 一覧を表示 |
| `make ssh-r1` 等 | 各 VM へ SSH |
| `make down` | VM 停止・削除、ネットワーク削除(ベースイメージは残す) |
| `make clean` | down + images/ も削除 |

## 構築フロー詳細

### 1. イメージ準備(初回のみ)

1. `10-fetch-images.sh` が VyOS rolling ISO と Alpine cloud qcow2 をダウンロード
   (チェックサム検証付き。済みならスキップ)
2. `11-build-vyos.sh` が vyos-vm-images(Docker 実行)で
   cloud-init 有効の `vyos-base.qcow2` をビルド

### 2. VM 作成(`make up`)

1. `virsh net-define && net-start` で labnet-* 5 ネットワークを作成
2. VM ごとに:
   - `qemu-img create -b <base> -F qcow2` で差分ディスク作成
   - `cloud-localds` で seed ISO 生成(cloud-init/ 配下の user-data から)
   - `virt-install --import` で定義・起動(NIC は mgmt → LAN/WAN の順で接続)
3. cloud-init が初回起動時に適用する内容:
   - **VyOS**: mgmt の静的 IP、ホスト名、SSH 有効化、演習用ユーザと公開鍵
   - **Alpine**: mgmt の静的 IP、SSH 公開鍵、apk で iperf3/tcpdump 等を導入
4. mgmt 経由で全 VM への SSH 到達を待ち合わせて完了

### 3. シナリオ適用(`make scenario-XX`)

`40-apply-scenario.sh` が各ルータに ssh し、シナリオの set コマンド列を
`configure → load/set → commit → save` で投入する。仕組みが単純なので、
**演習者が手で設定する場合の「模範解答」としてもそのまま読める**ことを重視する。

> 拡張ポイント: このスクリプトを Ansible(vyos.vyos コレクション)の playbook に
> 置き換えても、scenarios/ の設定ファイルはそのまま流用できる構造にしておく。

## 設計上の決め事

- 演習トラフィックと管理トラフィックを完全分離(mgmt は out-of-band)。
  シナリオ設定をミスしても SSH 経路は失われない
- すべてのスクリプトは**冪等**にする(再実行で壊れない)
- `images/` と生成物(差分 qcow2・seed ISO)は .gitignore に入れ、リポジトリには
  テキスト(設定・スクリプト)のみコミットする
- root 権限が要るのは libvirt 操作のみ(`libvirt` グループ所属で sudo 不要にする)
