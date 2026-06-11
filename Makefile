SHELL := /bin/bash
.DEFAULT_GOAL := help

SCENARIOS := $(sort $(notdir $(wildcard scenarios/*)))

help:
	@echo "VyOS/KVM ネットワーク演習ラボ"
	@echo ""
	@echo "  make prereqs           ホスト要件チェック(自動導入は scripts/00-prereqs.sh --install)"
	@echo "  make images            イメージ取得 + VyOS ベースイメージのビルド(初回のみ)"
	@echo "  make up                ネットワークと VM 5 台を作成・起動し、ベースラインを適用"
	@echo "  make scenario-<名前>   演習シナリオを適用"
	@echo "  make reset             全ルータをベースライン(00-base)へ戻す"
	@echo "  make status            状態表示(VM / ネットワーク / 管理 IP)"
	@echo "  make ssh-r1 など       各 VM へ SSH(r1 r2 r3 client1 client2)"
	@echo "  make down              VM・ネットワークを削除(イメージは残す)"
	@echo "  make clean             down に加えてイメージも削除"
	@echo ""
	@echo "シナリオ一覧: $(SCENARIOS)"

prereqs:
	scripts/00-prereqs.sh

images:
	scripts/10-fetch-images.sh
	scripts/11-build-vyos.sh

up:
	scripts/20-create-networks.sh
	scripts/30-create-vms.sh
	scripts/40-apply-scenario.sh 00-base

scenario-%:
	scripts/40-apply-scenario.sh $*

reset: scenario-00-base

status:
	scripts/90-status.sh

ssh-%:
	scripts/ssh.sh $*

down:
	scripts/50-destroy.sh

clean: down
	rm -rf images

.PHONY: help prereqs images up reset status down clean
