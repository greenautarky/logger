ARG BUILD_FROM=ghcr.io/hassio-addons/base:17.1.0
# hadolint ignore=DL3006
FROM ${BUILD_FROM}

# Set shell
#SHELL ["/bin/bash", "-o", "pipefail", "-c"]


ARG TARGETARCH
ARG FB_VERSION=3.0.7          # pin versions you trust
ARG TELEGRAF_VERSION=1.31.3

RUN set -eux; \
  apk add --no-cache curl tar jq gettext ca-certificates; \
  # Map Docker arch -> vendor asset names
  case "$TARGETARCH" in \
    amd64)  FB_ARCH="x86_64";   TG_ARCH="amd64" ;; \
    arm64)  FB_ARCH="aarch64";  TG_ARCH="arm64" ;; \
    arm)    FB_ARCH="armv7";    TG_ARCH="armv7" ;; \
    *) echo "Unsupported arch: $TARGETARCH" && exit 1 ;; \
  esac; \
  # ---- Fluent Bit ----
  FB_URL="https://github.com/fluent/fluent-bit/releases/download/v${FB_VERSION}/fluent-bit-${FB_VERSION}-linux-${FB_ARCH}.tar.gz"; \
  curl -fsSL "$FB_URL" | tar -xz -C /tmp; \
  mv /tmp/fluent-bit-${FB_VERSION}-linux-${FB_ARCH}/bin/* /usr/local/bin/; \
  mv /tmp/fluent-bit-${FB_VERSION}-linux-${FB_ARCH}/lib/* /usr/local/lib/ || true; \
  rm -rf /tmp/fluent-bit-*; \
  # ---- Telegraf ----
  TG_URL="https://dl.influxdata.com/telegraf/releases/telegraf-${TELEGRAF_VERSION}_linux_${TG_ARCH}.tar.gz"; \
  curl -fsSL "$TG_URL" | tar -xz -C /tmp; \
  mv /tmp/telegraf-${TELEGRAF_VERSION}/usr/bin/telegraf /usr/local/bin/; \
  rm -rf /tmp/telegraf-${TELEGRAF_VERSION}


# Copy root filesystem
COPY rootfs /
RUN chmod +x /run.sh

# This add-on runs on the host pid namespace, making it impossible
# to use S6-Overlay. Therefore the init system is disabled at this point.
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
