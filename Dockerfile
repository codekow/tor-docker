ARG ALPINE_VERSION="3"

# Tor builder
FROM --platform=$TARGETPLATFORM docker.io/library/alpine:${ALPINE_VERSION} as tor-builder

ARG TOR_VERSION="0.4.8.19"
RUN apk add --update --no-cache \
    git build-base automake autoconf make \
    build-base openssl-dev libevent-dev zlib-dev \
    xz-dev zstd-dev

# Install Tor from source
WORKDIR /tor
RUN git clone https://gitlab.torproject.org/tpo/core/tor.git --depth 1 --branch tor-"${TOR_VERSION}" /tor && \
      ./autogen.sh

# Notes:
# --enable-gpl is required to compile PoW anti-DoS: https://community.torproject.org/onion-services/advanced/dos/
# --enable-static-tor
RUN ./configure \
    --disable-asciidoc \
    --disable-manpage \
    --disable-html-manual \
    --enable-gpl && \
      make && \
      make install

# Build the lyrebird binary (cross-compiling)
ARG GO_VERSION=1.22

FROM --platform=$BUILDPLATFORM golang:${GO_VERSION}-alpine as lyrebird-builder
ARG LYREBIRD_VERSION="0.6.2"

RUN apk add --update --no-cache git && \
      git clone https://gitlab.torproject.org/tpo/anti-censorship/pluggable-transports/lyrebird.git --depth 1 --branch "lyrebird-${LYREBIRD_VERSION}" /lyrebird

# Build lyrebird
WORKDIR /lyrebird
RUN mkdir /out

ARG TARGETOS TARGETARCH
RUN --mount=type=cache,target=/root/.cache/go-build \
    --mount=type=cache,target=/go/pkg \
    CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
      go build -ldflags="-X main.lyrebirdVersion=${LYREBIRD_VERSION}" -o /out/lyrebird ./cmd/lyrebird

# Tor runner
FROM --platform=$TARGETPLATFORM docker.io/library/alpine:${ALPINE_VERSION} as runner

WORKDIR /app
ENV HOME=/app

RUN apk add --update --no-cache \
      libevent \
      xz-libs \
      zstd-libs

# install tor
RUN mkdir -p /usr/local/bin /usr/local/etc/tor /usr/local/share/tor
COPY --from=tor-builder /usr/local/bin/tor /usr/local/bin/tor
COPY --from=tor-builder /tor/src/tools/tor-resolve /usr/local/bin/.
COPY --from=tor-builder /tor/src/tools/tor-print-ed-signing-cert /usr/local/bin/.
COPY --from=tor-builder /tor/src/tools/tor-gencert /usr/local/bin/.
COPY --from=tor-builder /tor/contrib/client-tools/torify /usr/local/bin/.
COPY --from=tor-builder /tor/src/config/torrc.sample /usr/local/etc/tor/.
COPY --from=tor-builder /tor/src/config/geoip /usr/local/share/tor/.
COPY --from=tor-builder /tor/src/config/geoip6 /usr/local/share/tor/.

# install transports
COPY --from=lyrebird-builder /out/lyrebird /usr/local/bin/.

RUN mkdir -p /run/tor/service && \
    chgrp -R 0 /app /run/tor /var/lib /var/log && \
    chown -R 1001:0 /run/tor && \
    chmod -R g+w /app /run /var/lib /var/log

# change to non root
USER 1001

LABEL org.opencontainers.image.source "https://github.com/codekow/tor-docker"

ENTRYPOINT ["/usr/local/bin/tor"]
