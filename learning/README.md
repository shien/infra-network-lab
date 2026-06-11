# ネットワーク学習計画

本リポジトリのラボ(VyOS×KVM)を使って、ネットワークの基礎から VPN まで
全 15 章で学ぶ。1 章あたりの分量はおおよそ均等になるように分割してある。

## 進め方

- 時間制約は設けない。各章の**完了チェック**を満たしたら次の章へ進む
- 章を終えるごとに、感想・気づき・つまずいた点を `notes/` の対応ファイルに書く
- 実習でラボを壊しても `make reset`、駄目なら `make down && make up` でやり直せる
- 第 4 章以降の実習コマンドの詳細は各 `scenarios/XX/README.md` を参照
  (`make scenario-XX` の適用時にも表示される)

## 章一覧

| 章 | テーマ | 対応ラボ | 感想 |
|---|---|---|---|
| 1 | ネットワーク基礎(OSI/TCP-IP、カプセル化) | 座学 | [notes](notes/ch01-network-basics.md) |
| 2 | Ethernet と ARP | 座学(実機は第5章) | [notes](notes/ch02-ethernet-arp.md) |
| 3 | IP アドレッシング | [plan/02-architecture.md](../plan/02-architecture.md) | [notes](notes/ch03-ip-addressing.md) |
| 4 | ラボ環境の理解と構築 | `make up` / [00-base](../scenarios/00-base/README.md) | [notes](notes/ch04-lab-environment.md) |
| 5 | 同一 LAN の疎通とパケット観察 | [01-lan](../scenarios/01-lan/README.md)(LAN-A 側) | [notes](notes/ch05-lan-basics.md) |
| 6 | 静的ルーティング | [01-lan](../scenarios/01-lan/README.md) | [notes](notes/ch06-static-routing.md) |
| 7 | DHCP | [02-dhcp](../scenarios/02-dhcp/README.md) | [notes](notes/ch07-dhcp.md) |
| 8 | OSPF 入門 | [03-ospf](../scenarios/03-ospf/README.md) | [notes](notes/ch08-ospf-basics.md) |
| 9 | OSPF 応用 | [03-ospf](../scenarios/03-ospf/README.md) | [notes](notes/ch09-ospf-advanced.md) |
| 10 | BGP 入門 | [04-bgp](../scenarios/04-bgp/README.md) | [notes](notes/ch10-bgp-basics.md) |
| 11 | BGP 応用 | [04-bgp](../scenarios/04-bgp/README.md) | [notes](notes/ch11-bgp-advanced.md) |
| 12 | ステートフルファイアウォール | [05-firewall](../scenarios/05-firewall/README.md) | [notes](notes/ch12-firewall.md) |
| 13 | VPN 入門(WireGuard) | [06-vpn](../scenarios/06-vpn/README.md) | [notes](notes/ch13-vpn-wireguard.md) |
| 14 | VPN 応用(暗号化検証・IPsec) | [06-vpn](../scenarios/06-vpn/README.md) | [notes](notes/ch14-vpn-advanced.md) |
| 15 | 総合演習・トラブルシューティング | 全シナリオ | [notes](notes/ch15-troubleshooting.md) |

---

## 第1章 ネットワーク基礎(OSI/TCP-IP モデル、カプセル化)

- **目標**: 通信が階層モデルでどう分担されているかを説明できる
- **学ぶこと**
  - OSI 7 階層と TCP/IP 4 階層の対応、各層の役割
  - カプセル化とヘッダ(Ethernet フレーム / IP パケット / TCP・UDP セグメント)
  - 「同一セグメントは L2、セグメント間は L3」という基本原則
- **実習**: なし(第 5 章で tcpdump を使って実際のヘッダを観察する)
- **完了チェック**
  - [ ] 「client1 から client2 への ping」が各層で何に包まれて運ばれるかを図で描ける
  - [ ] L2 スイッチと L3 ルータの違いを一言で説明できる

## 第2章 Ethernet と ARP

- **目標**: 同一セグメント内の通信が MAC アドレスで成立する仕組みを説明できる
- **学ぶこと**
  - MAC アドレス、Ethernet フレームの構造、ブロードキャスト
  - ARP の動作(誰が・いつ・何を問い合わせるか)、ARP テーブル
  - スイッチの MAC アドレス学習とフラッディング
- **実習**: なし(本ラボの `labnet-*` は libvirt の仮想スイッチ。第 5 章で ARP を実機観察)
- **完了チェック**
  - [ ] 「IP は分かるが MAC が分からない」状態から通信が始まる流れを順に説明できる
  - [ ] ARP がセグメントを越えられない理由を説明できる

## 第3章 IP アドレッシング

- **目標**: CIDR 表記を読み書きでき、小規模ネットワークのアドレス設計ができる
- **学ぶこと**
  - IP アドレスとサブネットマスク、CIDR(/24, /30 など)、ネットワーク/ブロードキャストアドレス
  - プライベートアドレス(RFC 1918)
  - P2P リンクに /30 を使う理由
- **実習**: [plan/02-architecture.md](../plan/02-architecture.md) の IP 計画を読み、
  各セグメントのネットワークアドレス・ホスト範囲・ブロードキャストを自力で計算して照合する
- **完了チェック**
  - [ ] 10.0.12.0/30 の使えるホストアドレスを即答できる
  - [ ] 本ラボの全セグメント(lan-a/lan-b/wan-a/wan-b/mgmt)の範囲を説明できる

## 第4章 ラボ環境の理解と構築

- **目標**: ラボを自分で構築・破棄でき、構成要素の役割を説明できる
- **学ぶこと**
  - KVM/libvirt の基本(VM・仮想ネットワーク・virsh)
  - cloud-init による初期設定の仕組み(NoCloud、`vyos_config_commands`)
  - VyOS の操作モード(operational / configure)、`set` / `commit` / `save`
- **実習**
  ```sh
  make prereqs && make images && make up
  make status
  make ssh-r1     # show interfaces / show configuration
  virsh -c qemu:///system net-list | grep labnet   # 仮想スイッチの確認
  ```
- **完了チェック**
  - [ ] `make up` 〜 `make down` を一通り実行できた
  - [ ] r1 の eth0/eth1/eth2 がそれぞれどの仮想ネットワークに繋がるか言える
  - [ ] VyOS で設定を変更して commit / save する流れを実演できる

## 第5章 同一 LAN の疎通とパケット観察

- **目標**: L1〜L3 の理論(第 1〜3 章)を実パケットで確認する
- **学ぶこと**: ping(ICMP)、ARP テーブルの実物、tcpdump の基本的な使い方
- **実習**(`make scenario-01-lan` 適用後、LAN-A 側のみ使用)
  ```sh
  make ssh-client1
    ping 192.168.10.1            # 同一セグメントの疎通
    ip neigh                     # ARP テーブルに r1 の MAC が載る
    tcpdump -eni eth1 arp        # 別端末から ping して ARP 交換を観察
    tcpdump -ni eth1 icmp        # ICMP echo request/reply を観察
  ```
- **完了チェック**
  - [ ] tcpdump で ARP の who-has / is-at を捕捉できた
  - [ ] フレームの送信元/宛先 MAC が「クライアント⇔r1」になっていることを確認できた

## 第6章 静的ルーティング

- **目標**: 経路表に基づく転送を理解し、静的経路で 3 ルータ越しの疎通を作れる
- **学ぶこと**: 経路表(connected/static)、ネクストホップ、デフォルトルート、
  「行きと帰りの両方に経路が要る」こと
- **実習**: [scenarios/01-lan/README.md](../scenarios/01-lan/README.md)
  - client1 → client2 の traceroute で r1 → r2 → r3 を確認
  - r2 の静的経路を 1 本消して(`delete protocols static route ...`)、
    どこで通信が落ちるかを観察 → 戻す(または `make scenario-01-lan` で再適用)
- **完了チェック**
  - [ ] `show ip route` の C / S の意味を説明できる
  - [ ] 経路を消したとき「どちら向きの通信が・どこで」失敗するか予想どおりだった

## 第7章 DHCP

- **目標**: DHCP の 4 way ハンドシェイクと配布オプションを理解し、VyOS で設定できる
- **学ぶこと**: DISCOVER/OFFER/REQUEST/ACK、リース時間、配布オプション
  (default-router / name-server)、固定割当(static-mapping)
- **実習**: [scenarios/02-dhcp/README.md](../scenarios/02-dhcp/README.md)
  - `tcpdump -ni eth1 port 67 or port 68` を流しながら client1 で DHCP 再取得し、
    4 つのメッセージを捕捉する
  - 発展課題: リース時間変更と固定割当
- **完了チェック**
  - [ ] DORA の 4 メッセージを tcpdump で確認できた
  - [ ] `show dhcp server leases` でリースを確認し、固定割当を設定できた

## 第8章 OSPF 入門

- **目標**: 動的ルーティングの利点を理解し、OSPF の隣接確立と経路伝搬を観察できる
- **学ぶこと**: 静的経路の限界、OSPF の隣接関係(Hello、状態遷移と Full)、
  ルータ ID、エリア、LSA とリンクステート DB の概要、passive-interface
- **実習**: [scenarios/03-ospf/README.md](../scenarios/03-ospf/README.md)
  ```sh
  make ssh-r2
    show ip ospf neighbor        # r1 / r3 と Full
    show ip ospf database        # LSA を眺める
    show ip route ospf           # O 経路で両 LAN が見える
  ```
  - r1 で `show ip route` を静的ルーティング時(第 6 章)と見比べる
- **完了チェック**
  - [ ] 隣接が Full になるまでの大まかな流れを説明できる
  - [ ] 「静的経路を 1 本も書いていないのに両 LAN が疎通する」理由を説明できる

## 第9章 OSPF 応用

- **目標**: メトリックによる経路選択と、障害時の自動再収束を体感する
- **学ぶこと**: OSPF コスト、最短経路計算(SPF)の考え方、再収束、タイマー
- **実習**(scenario-03-ospf のまま)
  - `set protocols ospf interface eth2 cost 100` でコストを変え、経路と traceroute の変化を観察
  - ホスト側からリンク疑似障害を注入し、ping の途切れ〜回復を観察:
    `virsh -c qemu:///system domif-setlink lab-r2 <vnet名> down`(`virsh domiflist lab-r2` で確認、up で復旧)
  - `show ip ospf neighbor` が Dead Timer でどう変化するかを見る
- **完了チェック**
  - [ ] コスト変更で経路が変わることを traceroute で確認できた
  - [ ] 障害注入から経路回復までの流れ(隣接ダウン検知 → 再計算)を説明できる

## 第10章 BGP 入門

- **目標**: AS 間ルーティングの考え方を理解し、eBGP ピアと経路広告を設定・確認できる
- **学ぶこと**: AS と AS 番号、eBGP/iBGP の違い、ピアリング(neighbor)、
  network 文による経路広告、トランジット
- **実習**: [scenarios/04-bgp/README.md](../scenarios/04-bgp/README.md)
  ```sh
  make ssh-r2
    show ip bgp summary          # 2 ピアが Established
    show ip bgp                  # 経路と AS パス
  make ssh-r1
    show ip bgp neighbors 10.0.12.2 advertised-routes
  ```
- **完了チェック**
  - [ ] OSPF(第 8 章)と BGP の使い分け(AS 内 vs AS 間)を説明できる
  - [ ] 192.168.20.0/24 が AS パス `65000 65002` で見える理由を説明できる

## 第11章 BGP 応用

- **目標**: BGP のポリシー制御(経路フィルタ)を実装できる
- **学ぶこと**: AS パスによるループ防止、prefix-list、route-map、
  経路フィルタの適用方向(import/export)
- **実習**(scenario-04-bgp のまま)
  - r2 に prefix-list + route-map を設定し、192.168.20.0/24 の r1 向け広告を止める
    → r1 の `show ip bgp` から消え、client1 → client2 が落ちることを確認 → 解除
  - 発展: 経路フィルタを LAN-B 側だけに適用し、片方向だけ通信が壊れる状態を観察する
- **完了チェック**
  - [ ] フィルタ適用前後の `show ip bgp` の差分を説明できる
  - [ ] 「広告しない = 相手が経路を知らない = 戻りも含めて通信不能」を実例で確認できた

## 第12章 ステートフルファイアウォール

- **目標**: ステートフル FW の考え方を理解し、方向別のポリシーを実装・検証できる
- **学ぶこと**: コネクション追跡(established/related)、default-action とルール順序、
  forward/input チェインの違い、ログの読み方
- **実習**: [scenarios/05-firewall/README.md](../scenarios/05-firewall/README.md)
  - LAN-A 発の iperf3 は通り、WAN 側からの新規 TCP は落ちることを確認
  - `show firewall` のカウンタと `show log firewall` でルールの命中を確認
  - 発展課題: ICMP 許可ルールの削除、特定ポートのみの許可
- **完了チェック**
  - [ ] 「行きは通るのに戻りが通る理由」(state)を説明できる
  - [ ] ルールを 1 つ変えたときの挙動変化をログとカウンタで裏付けられる

## 第13章 VPN 入門(WireGuard site-to-site)

- **目標**: トンネリングの概念を理解し、site-to-site VPN で LAN 同士を接続できる
- **学ぶこと**: トンネルとオーバーレイ、公開鍵ペアによるピア認証、
  allowed-ips、トンネル経由のルーティング(interface route)
- **実習**: [scenarios/06-vpn/README.md](../scenarios/06-vpn/README.md)
  ```sh
  make ssh-r1
    show interfaces wireguard wg0   # latest handshake を確認
    ping 10.99.0.2                  # トンネル対向
  make ssh-client1
    traceroute 192.168.20.100       # r2 がホップに現れない
  ```
- **完了チェック**
  - [ ] 「r2 は LAN への経路を持たないのに LAN 同士が疎通する」仕組みを図で説明できる
  - [ ] wg0 の allowed-ips が何を制御しているか説明できる

## 第14章 VPN 応用(暗号化の検証・IPsec)

- **目標**: 「暗号化されている」ことを自分で検証し、別方式(IPsec)と比較できる
- **学ぶこと**: 中間者から見える情報(外側ヘッダのみ)、UDP/51820、
  IPsec(IKEv2)の概要と WireGuard との違い
- **実習**(scenario-06-vpn のまま)
  - r2 で `sudo tcpdump -ni eth1 udp port 51820` を流しながら client 間で通信し、
    平文(192.168.x.x や HTTP 文字列)が見えないことを確認
  - 発展: scenarios/06-vpn を参考に、WireGuard を止めて IPsec(`set vpn ipsec ...`)で
    同じ site-to-site を自力構築してみる
- **完了チェック**
  - [ ] r2 の tcpdump で内側のアドレス・ペイロードが見えないことを確認できた
  - [ ] WireGuard と IPsec の違いを 3 点挙げられる

## 第15章 総合演習・トラブルシューティング

- **目標**: これまでの知識を総動員して、原因不明の障害を切り分けられる
- **学ぶこと**: 切り分けの定石(下の層から / 近くから遠くへ)、
  ping・traceroute・tcpdump・show コマンドの使い分け
- **実習**
  - `make down && make up` 後、各シナリオを順に適用し、各章の完了チェックを高速に再走する
  - セルフ障害演習: 任意のシナリオで自分(または他人)に設定を 1 箇所壊してもらい、
    show/tcpdump だけで原因を特定する(例: 経路 1 本削除、FW ルール追加、DHCP レンジ変更)
  - 仕上げ: `make reset` 状態から scenarios/ を見ずに 01〜06 相当の設定を自力投入する
- **完了チェック**
  - [ ] 壊された設定を 3 パターン以上、自力で特定・復旧できた
  - [ ] 模範解答を見ずに LAN〜VPN までの構成を一通り組めた

---

学習が終わったら、`notes/` の感想を読み返して全体の振り返りを書くのがおすすめ。
