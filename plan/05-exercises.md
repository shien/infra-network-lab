# 05. 演習シナリオ一覧

トポロジは固定のまま、`make scenario-XX` で設定だけを切り替える。
番号順に難易度が上がり、後の演習は前の演習の設定を土台にする。

## 00. ベースライン(00-base)

全演習の出発点。mgmt の IP と SSH のみ設定済みで、演習ネットワーク側は未設定。
`make reset` でいつでもこの状態に戻せる。

## 01. シンプルな LAN と静的ルーティング(01-lan)

- **目標**: インターフェースへの IP 設定、同一セグメント疎通、静的経路の理解
- **使用機器**: r1, r3, client1, client2(r2 は静的経路の中継)
- **内容**: 各 LAN / WAN に IP を設定し、静的ルートだけで client1 ⇔ client2 を疎通させる
- **確認**: `ping`, `traceroute`(経路が r1 → r2 → r3 を通ること)、
  VyOS `show ip route`

## 02. DHCP(02-dhcp)

- **目標**: VyOS の DHCP サーバ設定と、リース・オプション配布の理解
- **使用機器**: r1(lan-a へ配布)、r3(lan-b へ配布)、client1, client2
- **内容**: client の静的 IP を外して DHCP 取得に切り替え。
  レンジ 192.168.x.100–199、GW・DNS オプション、固定割当(static mapping)も試す
- **確認**: client 側 `ip addr` / リース取得ログ、VyOS `show dhcp server leases`

## 03. OSPF(03-ospf)

- **目標**: 動的ルーティングの基礎。隣接関係・LSA・経路の自動伝搬・障害時の再収束
- **使用機器**: r1, r2, r3(エリア 0 のシングルエリア)
- **内容**: 01 の静的経路を削除し、loopback(10.255.0.x)をルータ ID として
  OSPF で LAN プレフィックスを伝搬。リンクコスト変更や
  `virsh domif-setlink` による疑似障害で再収束を観察する
- **確認**: `show ip ospf neighbor`, `show ip ospf route`, 障害時の traceroute 変化

## 04. BGP(04-bgp)

- **目標**: eBGP ピアリング、経路広告、AS パスの理解
- **使用機器**: r1(AS65001)、r2(AS65000・ISP 役)、r3(AS65002)
- **内容**: OSPF を止め、r1–r2 / r2–r3 で eBGP を確立。各 AS が自 LAN を広告し、
  r2 がトランジットとして経路を中継する。prefix-list / route-map での
  経路フィルタも発展課題とする
- **確認**: `show ip bgp summary`, `show ip bgp`(AS パス)、client 間疎通

## 05. Firewall(05-firewall)

- **目標**: ステートフルファイアウォールとゾーンの考え方
- **使用機器**: r1(LAN ゾーン / WAN ゾーン)、client1、client2(外部役)
- **内容**: 04 の経路を維持したまま、r1 に「LAN → WAN は許可、
  WAN → LAN は戻り(established/related)と ICMP のみ許可」のルールを実装。
  ログ取得とルール順序の効果も確認する
- **確認**: client2 → client1 の新規接続が拒否され、逆方向は通ること。
  `show firewall`, ログ出力

## 06. VPN(06-vpn)

- **目標**: site-to-site VPN によるトンネリングと「中間網に LAN を見せない」設計の理解
- **使用機器**: r1 ⇔ r3(トンネル終端)、r2(LAN 経路を知らないインターネット役)
- **内容**: r2 から LAN 向けの経路を消し(WAN アドレスのみ到達可能な状態)、
  r1–r3 間に WireGuard トンネル(10.99.0.0/30)を張って LAN 同士を再疎通させる。
  発展課題として IPsec(IKEv2)版も用意する
- **確認**: r2 で `tcpdump` し、client 間トラフィックが暗号化(UDP/51820)されて
  見えること。`show interfaces wireguard`, トンネル経由の traceroute

## 演習の進め方(共通)

1. `make scenario-XX` で「完成形」を一括投入して動作を観察する、または
   `make reset` 後に scenarios/XX/*.cfg を**模範解答として参照しながら手で設定**する
2. 確認コマンドは各シナリオの README(実装フェーズで scenarios/XX/README.md として作成)に記載
3. 崩れたら `make reset`、それでもダメなら `make down && make up` で完全再構築(数分で戻る)
