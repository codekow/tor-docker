.PHONY: all
all: build

# Dockerfile.quick installs Tor using pre-built binaries
.PHONY: quick
quick:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg TOR_VERSION=0.4.8.19 \
		--tag ghcr.io/codekow/tor-bin:0.4.8.19 \
		--tag ghcr.io/codekow/tor-bin:latest \
		--squash \
		-f Dockerfile.quick \
		.

# Dockerfile builds Tor from source
.PHONY: build
build:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg TOR_VERSION=0.4.8.19 \
		--tag ghcr.io/codekow/tor:0.4.8.19 \
		--tag ghcr.io/codekow/tor:latest \
		--squash \
		-f Dockerfile \
		.

# Dockerfile.obfs4 builds lyrebird
.PHONY: obfs4
obfs4:
	docker buildx build \
		--platform=linux/amd64,linux/arm,linux/arm64 \
		--build-arg LYREBIRD_VERSION=0.6.2 \
		--build-arg GO_VERSION=1.22 \
		--tag ghcr.io/codekow/obfs4:0.6.2 \
		--tag ghcr.io/codekow/obfs4:latest \
		--squash \
		-f Dockerfile.obfs4 \
		.
