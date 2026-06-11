# 01. 必要スペック(ホスト要件・VM スペック)

## ホストマシン要件

| 項目 | 最小 | 推奨 | 備考 |
|---|---|---|---|
| OS | Ubuntu 22.04 LTS | Ubuntu 24.04 LTS | Server / Desktop どちらでも可 |
| CPU | 2 コア(VT-x / AMD-V 有効) | 4 コア以上 | BIOS/UEFI で仮想化支援を有効にすること |
| RAM | 6 GB | 8 GB 以上 | ラボが約 3.5 GB を消費。ホスト OS 分の余裕が必要 |
| ディスク空き | 20 GB | 30 GB 以上 | ISO + ベースイメージ + VM 5 台分(thin provisioning) |
| ネットワーク | インターネット接続 | 同左 | イメージのダウンロードに必要(構築後はオフライン可) |

仮想化支援が有効かは以下で確認できる(1 以上なら OK):

```sh
egrep -c '(vmx|svm)' /proc/cpuinfo
```

ネストした仮想化は不要(VyOS / Alpine はネスト VM を作らない)。
クラウド VM 上で動かす場合のみ、nested virtualization 対応インスタンスが必要。

## VM スペック

| VM 名 | 役割 | OS | vCPU | RAM | ディスク |
|---|---|---|---|---|---|
| r1 | サイト A エッジルータ(AS65001) | VyOS 1.5 rolling | 1 | 1 GB | 10 GB(thin) |
| r2 | ISP / コアルータ(AS65000) | VyOS 1.5 rolling | 1 | 1 GB | 10 GB(thin) |
| r3 | サイト B エッジルータ(AS65002) | VyOS 1.5 rolling | 1 | 1 GB | 10 GB(thin) |
| client1 | サイト A クライアント | Alpine Linux(cloud イメージ) | 1 | 256 MB | 約 1 GB |
| client2 | サイト B クライアント | Alpine Linux(cloud イメージ) | 1 | 256 MB | 約 1 GB |

- VyOS の公式最小要件は RAM 512 MB だが、余裕を見て 1 GB とする
  (ホストが厳しい場合は 512 MB まで削減可能)
- ルータのディスクは qcow2 の **backing file 方式**(ベースイメージ 1 つ + 差分 3 つ)で
  実消費を数 GB に抑える
- クライアントは ping / traceroute / iperf3 / DHCP クライアントが動けば十分なので
  Alpine の 256 MB で足りる

## リソース合計

| 項目 | 合計 |
|---|---|
| vCPU | 5(オーバーコミット可。物理 2 コアでも動作する) |
| RAM | 約 3.5 GB |
| ディスク実消費 | 約 5〜8 GB(ISO・ベースイメージ込み) |
