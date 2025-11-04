

# Use the base image provided by the workflow (should be Alpine for all arches)
ARG BUILD_FROM
# hadolint ignore=DL3006
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
ARG FB_VERSION=4.0.13



ENV LD_LIBRARY_PATH="/usr/local/lib"

# --- Tools + Fluent Bit (Alpine/musl, minimal) ---
RUN apk add --no-cache ca-certificates curl jq tar

# Install Fluent Bit (musl, minimal, dynamic) for Alpine
RUN ARCH="${TARGETARCH:-$BUILD_ARCH}"; \
    case "$ARCH" in \
      amd64|x86_64)   FB_ARCH="x86_64" ;; \
      arm64|aarch64)  FB_ARCH="aarch64" ;; \
      arm|armv7)      FB_ARCH="armv7" ;; \
      *) echo "Unsupported arch: ${ARCH}" >&2; exit 1 ;; \
    esac; \
    FB_URL="https://github.com/fluent/fluent-bit/releases/download/v${FB_VERSION}/fluent-bit-${FB_VERSION}-linux-${FB_ARCH}.tar.gz"; \
    echo "Downloading Fluent Bit: ${FB_URL}"; \
    curl -fL --retry 3 --retry-delay 2 -o /tmp/fluent-bit.tgz "${FB_URL}"; \
    tar -tzf /tmp/fluent-bit.tgz >/dev/null; \
    mkdir -p /tmp/fb && tar -xzf /tmp/fluent-bit.tgz -C /tmp/fb; \
    FB_BIN="$(find /tmp/fb -type f -name fluent-bit | head -n1)"; \
    test -x "${FB_BIN}"; \
    install -m0755 "${FB_BIN}" /usr/bin/fluent-bit; \
    rm -rf /tmp/fluent-bit.tgz /tmp/fb

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
