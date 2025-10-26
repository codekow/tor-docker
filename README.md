# tor-docker

[![Build multiarch image - latest](https://github.com/codekow/tor-docker/actions/workflows/main.yml/badge.svg)](https://github.com/codekow/tor-docker/actions/workflows/main.yml)
[![Build multiarch image - tag](https://github.com/codekow/tor-docker/actions/workflows/main-tag.yml/badge.svg)](https://github.com/codekow/tor-docker/actions/workflows/main-tag.yml)

`Tor` daemon multiarch container.

Additional transport plugins included in the image:

- `obfs4proxy`

Tested architectures:

- `amd64`
- `arm`
- `arm64`

Source code:

- https://gitlab.torproject.org/tpo/core/tor
- https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird

Downloads:

- https://www.torproject.org/download/tor

Used by:

- [codekow/tor-controller](https://github.com/codekow/tor-controller)

## Tor

Tor is an anonymity network that provides:

- privacy
- enhanced tamper proofing
- freedom from network surveillance
- NAT traversal

## How to

## Standard build

Builds Tor from source. Method used to create releases in this repo.

```bash
make
```

## Quick build

Installs pre-built Tor from Alpine's repositories. Useful for testing/troubleshooting.

WARNING: some Tor features might be missing, depending on the [Alpine community build setup](https://github.com/alpinelinux/aports/tree/master/community/tor)

```bash
make quick
```

## Usage

```shell
docker pull ghcr.io/codekow/tor
```
