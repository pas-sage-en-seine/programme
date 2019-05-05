.DEFAULT_GOAL := deploy
.PHONY: build deploy qrcode
export MM_ENV := production

RSYNC := rsync --progress -ahxvAHX

source/images/qrcode.png: giggity.json
	gzip -9 < "$<" | qrencode -8t png -o "$@"
qrcode: source/images/qrcode.png

build: qrcode
	middleman build

deploy: qrcode
	middleman deploy
