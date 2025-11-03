# syntax=docker/dockerfile:1.6

ARG BUILD_FROM=ghcr.io/hassio-addons/base:17.1.0
FROM ${BUILD_FROM}

# Use ash like the HA base; fail early on errors
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

# ----- Build args -----
# Provided by HA builder / your build.yaml
ARG TARGETARCH
ARG BUILD_ARCH
ARG TELEGRAF_VERSION=1.36.3   # set in build.yaml args (can override there)

# Optional HA builder metadata (if present they’ll be used for labels)
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Needed for Fluent Bit plugins on Alpine and to silence linter warnings
ENV LD_LIBRARY_PATH="/usr/local/lib"

# ----- Packages + binaries -----
RUN set -eux; \
  apk add --no-cache curl tar jq gettext ca-certificates libstdc++ libgcc; \
  apk add --no-cache --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing fluent-bit; \
  \
  # Prefer TARGETARCH (buildx) and fall back to HA's BUILD_ARCH
  ARCH="${TARGETARCH:-$BUILD_ARCH}"; \
  case "$ARCH" in \
    amd64|x86_64)   TG_ARCH="amd64" ;; \
    arm64|aarch64)  TG_ARCH="arm64" ;; \
    arm|armv7)      TG_ARCH="armhf" ;; \
    *) echo "Unsupported arch: ${ARCH}" >&2; exit 1 ;; \
  esac; \
  echo "Resolved ARCH=${ARCH} -> TG_ARCH=${TG_ARCH}"; \
  \
  # -------- Telegraf --------
  TG_URL="https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${TG_ARCH}.tar.gz"; \
  echo "Downloading Telegraf: ${TG_URL}"; \
  curl -fL --retry 3 --retry-delay 2 -o /tmp/telegraf.tgz "${TG_URL}"; \
  tar -tzf /tmp/telegraf.tgz >/dev/null; \
  mkdir -p /tmp/tg && tar -xzf /tmp/telegraf.tgz -C /tmp/tg; \
  TG_BIN="$(find /tmp/tg -type f -path '*/usr/bin/telegraf' | head -n1)"; \
  test -x "${TG_BIN}"; \
  install -m 0755 "${TG_BIN}" /usr/local/bin/telegraf; \
  rm -rf /tmp/telegraf.tgz /tmp/tg

# ----- Add-on rootfs -----
COPY rootfs /
RUN chmod +x /run.sh

# This add-on runs in host PID namespace; disable s6 init
ENTRYPOINT []
CMD ["/run.sh"]

# ----- Labels (optional but nice) -----
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