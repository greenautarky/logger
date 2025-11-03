# syntax=docker/dockerfile:1.6

# Point to Debian base from config.yaml (per-arch). This default is just a fallback.
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/armv7:6.0.0
ARG TELEGRAF_VERSION=1.36.3

# Final image (Debian-based HA add-on base)
FROM ${BUILD_FROM}

# Use /bin/sh on Debian base (no ash here)
SHELL ["/bin/sh", "-ec"]

# Common labels args from HA builder
ARG TARGETARCH
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

ENV LD_LIBRARY_PATH="/usr/local/lib"

# ---- Install tools and Fluent Bit (glibc) ----
# Add Fluent Bit official APT repo, then install fluent-bit (armv7 => armhf)
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl jq gettext-base gnupg tar \
 && curl -fsSL https://packages.fluentbit.io/fluentbit.key \
    | gpg --dearmor -o /usr/share/keyrings/fluentbit.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/fluentbit.gpg] https://packages.fluentbit.io/debian/bookworm bookworm main" \
    > /etc/apt/sources.list.d/fluent-bit.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends fluent-bit \
 && rm -rf /var/lib/apt/lists/*

# ---- Install Telegraf (portable tarball) ----
# Map Docker arch to Influx tarball arch names
RUN ARCH="${TARGETARCH:-$BUILD_ARCH}"; \
    case "$ARCH" in \
      amd64|x86_64)   TG_ARCH="amd64" ;; \
      arm64|aarch64)  TG_ARCH="arm64" ;; \
      arm|armv7)      TG_ARCH="armhf" ;; \
      *) echo "Unsupported arch: ${ARCH}" >&2; exit 1 ;; \
    esac; \
    TG_URL="https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${TG_ARCH}.tar.gz"; \
    echo "Downloading Telegraf: ${TG_URL}"; \
    curl -fL --retry 3 --retry-delay 2 -o /tmp/telegraf.tgz "${TG_URL}"; \
    tar -tzf /tmp/telegraf.tgz >/dev/null; \
    mkdir -p /tmp/tg && tar -xzf /tmp/telegraf.tgz -C /tmp/tg; \
    TG_BIN="$(find /tmp/tg -type f -path '*/usr/bin/telegraf' | head -n1)"; \
    test -x "${TG_BIN}"; \
    install -m0755 "${TG_BIN}" /usr/local/bin/telegraf; \
    rm -rf /tmp/telegraf.tgz /tmp/tg

# Your filesystem overlay and entry
COPY rootfs /
RUN chmod +x /run.sh

# For add-ons you usually let s6 handle services; but if you're testing, this is fine:
ENTRYPOINT []
CMD ["/run.sh"]

# Labels
LABEL \
  io.hass.name="${BUILD_NAME}" \
  io.hass.description="${BUILD_DESCRIPTION}" \
  io.hass.arch="${BUILD_ARCH}" \
  io.hass.type="addon" \
  io.hass.version="${BUILD_VERSION}" \
  maintainer="Thomas Taube" \
  org.opencontainers.image.title="${BUILD_NAME}" \
  org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
  org.opencontainers.image.vendor="Greenautarky" \
  org.opencontainers.image.authors="Thomas Taube" \
  org.opencontainers.image.url="https://github.com/${BUILD_REPOSITORY}" \
  org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
  org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
  org.opencontainers.image.created="${BUILD_DATE}" \
  org.opencontainers.image.revision="${BUILD_REF}" \
  org.opencontainers.image.version="${BUILD_VERSION}"
