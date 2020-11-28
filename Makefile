ROLE=web

all: dist

deps:
	npm i

dist:
	rm packer-$(ROLE).json || true
	jk generate -p role=$(ROLE) packer.ts

validate: dist
	packer validate packer-$(ROLE).json

debug: dist
	packer build --debug packer-$(ROLE).json

build: dist
	packer build packer-$(ROLE).json
