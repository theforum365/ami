SHELL=/bin/bash

all: dist

deps:
	npm i

dist:
	rm packer.json || true
	jk generate packer.ts

validate: dist
	packer validate packer.json

debug: dist
	packer build --debug packer.json

build: dist
	packer build packer.json
