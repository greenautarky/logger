# syntax=docker/dockerfile:1.6
ARG BUILD_FROM=ghcr.io/hassio-addons/debian-base/armv7:6.0.0
FROM ${BUILD_FROM}

SHELL ["/bin/sh","-ec"]

# HA builder args (left as-is)
ARG TARGETARCH
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION
ARG TELEGRAF_VERSION=1.36.3

ENV LD_LIBRARY_PATH="/usr/local/lib"

# --- Tools + Fluent Bit (glibc) ---
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      ca-certificates curl jq gettext-base gnupg tar findutils \
 && curl -fsSL https://packages.fluentbit.io/fluentbit.key \
    | gpg --dearmor -o /usr/share/keyrings/fluentbit.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/fluentbit.gpg] https://packages.fluentbit.io/debian/bookworm bookworm main" \
    > /etc/apt/sources.list.d/fluent-bit.list \
 && apt-get update \
 && apt-get install -y --no-install-recommends fluent-bit \
 && rm -rf /var/lib/apt/lists/*

# --- Telegraf (tarball, arch-mapped) ---
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

# Your overlay (configs, s6 services, etc.)
COPY rootfs /

# IMPORTANT: do NOT override entrypoint/cmd — keep s6 from the base image
# (If you had ENTRYPOINT [] / CMD ["/run.sh"], remove them.)
# The add-on should start services via s6 (e.g., /etc/s6-overlay/s6-rc.d/<svc>/run)
# If you currently start via /run.sh, migrate that to s6 longruns.
  
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
