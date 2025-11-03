# Set shell

#SHELL ["/bin/bash", "-o", "pipefail", "-c"]

ARG BUILD_FROM=ghcr.io/hassio-addons/base:17.1.0
FROM ${BUILD_FROM}

# Make /bin/ash strict
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]

ARG TARGETARCH
ARG BUILD_ARCH
ARG FB_VERSION=3.0.7        # keep your pinned versions
ARG TELEGRAF_VERSION=1.31.3

# Ensure libstdc++ for fluent-bit; define LD_LIBRARY_PATH to avoid warnings
ENV LD_LIBRARY_PATH="/usr/local/lib"

RUN set -eux; \
  apk add --no-cache curl tar jq gettext ca-certificates libstdc++ libgcc; \
  \
  # Determine arch (prefer TARGETARCH from buildx, fallback to HA BUILD_ARCH)
  ARCH="${TARGETARCH:-$BUILD_ARCH}"; \
  case "$ARCH" in \
    amd64|x86_64)   FB_ARCH="x86_64";  TG_ARCH="amd64" ;; \
    arm64|aarch64)  FB_ARCH="aarch64"; TG_ARCH="arm64" ;; \
    arm|armv7)      FB_ARCH="armv7";   TG_ARCH="armhf" ;; \
    *) echo "Unsupported arch: ${ARCH}" >&2; exit 1 ;; \
  esac; \
  echo "Resolved ARCH=${ARCH} -> FB_ARCH=${FB_ARCH}, TG_ARCH=${TG_ARCH}"; \
  \
  # -------- Fluent Bit --------
  FB_URL="https://github.com/fluent/fluent-bit/releases/download/v${FB_VERSION}/fluent-bit-${FB_VERSION}-linux-${FB_ARCH}.tar.gz"; \
  echo "Downloading Fluent Bit from: ${FB_URL}"; \
  curl -fL --retry 3 --retry-delay 2 -o /tmp/fluent-bit.tgz "${FB_URL}"; \
  tar -tzf /tmp/fluent-bit.tgz >/dev/null; \
  mkdir -p /tmp/fb && tar -xzf /tmp/fluent-bit.tgz -C /tmp/fb; \
  FB_DIR="/tmp/fb/fluent-bit-${FB_VERSION}-linux-${FB_ARCH}"; \
  test -x "${FB_DIR}/bin/fluent-bit"; \
  mv "${FB_DIR}/bin/"* /usr/local/bin/; \
  if [ -d "${FB_DIR}/lib" ]; then mv "${FB_DIR}/lib/"* /usr/local/lib/; fi; \
  rm -rf /tmp/fluent-bit.tgz /tmp/fb; \
  \
  # -------- Telegraf --------
  TG_URL="https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${TG_ARCH}.tar.gz"; \
  echo "Downloading Telegraf from: ${TG_URL}"; \
  curl -fL --retry 3 --retry-delay 2 -o /tmp/telegraf.tgz "${TG_URL}"; \
  tar -tzf /tmp/telegraf.tgz >/dev/null; \
  mkdir -p /tmp/tg && tar -xzf /tmp/telegraf.tgz -C /tmp/tg; \
  # Influx tarball structure: telegraf-<ver>/usr/bin/telegraf
  TG_BIN="$(find /tmp/tg -type f -path '*/usr/bin/telegraf' | head -n1)"; \
  test -x "${TG_BIN}"; \
  mv "${TG_BIN}" /usr/local/bin/telegraf; \
  rm -rf /tmp/telegraf.tgz /tmp/tg


COPY rootfs /
RUN chmod +x /run.sh

ENTRYPOINT []
CMD ["/run.sh"]

# Build arguments
ARG BUILD_ARCH
ARG BUILD_DATE
ARG BUILD_DESCRIPTION
ARG BUILD_NAME
ARG BUILD_REF
ARG BUILD_REPOSITORY
ARG BUILD_VERSION

# Labels
LABEL \
    io.hass.name="${BUILD_NAME}" \
    io.hass.description="${BUILD_DESCRIPTION}" \
    io.hass.arch="${BUILD_ARCH}" \
    io.hass.type="addon" \
    io.hass.version=${BUILD_VERSION} \
    maintainer="Thomas Taube " \
    org.opencontainers.image.title="${BUILD_NAME}" \
    org.opencontainers.image.description="${BUILD_DESCRIPTION}" \
    org.opencontainers.image.vendor="Home Assistant Community Log Add-ons" \
    org.opencontainers.image.authors="Thomas Taube " \
    org.opencontainers.image.licenses="MIT" \
    org.opencontainers.image.url="https://addons.community" \
    org.opencontainers.image.source="https://github.com/${BUILD_REPOSITORY}" \
    org.opencontainers.image.documentation="https://github.com/${BUILD_REPOSITORY}/blob/main/README.md" \
    org.opencontainers.image.created=${BUILD_DATE} \
    org.opencontainers.image.revision=${BUILD_REF} \
    org.opencontainers.image.version=${BUILD_VERSION}
