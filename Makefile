VERSION ?= n5.1-dev
CACHE ?= --no-cache=1
FULLVERSION ?= n5.1-dev
archs ?= amd64 arm32v5 arm32v7 arm64v8 i386 aarch64

.PHONY: all build publish latest
all: build publish latest
qemu-aarch64-static:
	cp /usr/bin/qemu-aarch64-static .
qemu-arm-static:
	cp /usr/bin/qemu-arm-static .
build: qemu-aarch64-static qemu-arm-static
	$(foreach arch,$(archs), \
		cat Dockerfile | sed "s/FROM debian:stable-slim/FROM ${arch}\/debian:stable-slim/g" > .Dockerfile; \
		docker build -t jaymoulin/rpi-plex-video-converter:${VERSION}-$(arch) -f .Dockerfile ${CACHE} .;\
	)
publish:
	docker push jaymoulin/rpi-plex-video-converter -a
	cat manifest.yml | sed "s/\$$VERSION/${VERSION}/g" > manifest.yaml
	cat manifest.yaml | sed "s/\$$FULLVERSION/${FULLVERSION}/g" > manifest2.yaml
	mv manifest2.yaml manifest.yaml
	manifest-tool push from-spec manifest.yaml
latest: build
	FULLVERSION=latest VERSION=${VERSION} make publish
