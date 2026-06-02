FROM debian:trixie-slim@sha256:109e2c65005bf160609e4ba6acf7783752f8502ad218e298253428690b9eaa4b

# renovate: datasource=deb depName=wireguard-tools registryUrl=https://deb.debian.org/debian?suite=trixie&components=main&binaryArch=amd64
ENV WIREGUARD_TOOLS_VERSION="1.0.20210914-3"

# renovate: datasource=deb depName=iproute2 registryUrl=https://deb.debian.org/debian?suite=trixie&components=main&binaryArch=amd64
ENV IPROUTE2_VERSION="6.15.0-1"

# renovate: datasource=deb depName=nftables registryUrl=https://deb.debian.org/debian?suite=trixie&components=main&binaryArch=amd64
ENV NFTABLES_VERSION="1.1.3-1"

# renovate: datasource=deb depName=tini registryUrl=https://deb.debian.org/debian?suite=trixie&components=main&binaryArch=amd64
ENV TINI_VERSION="0.19.0-3+b7"

# renovate: datasource=deb depName=sudo registryUrl=https://deb.debian.org/debian?suite=trixie&components=main&binaryArch=amd64
ENV SUDO_VERSION="1.9.16p2-3+deb13u2"

RUN apt-get update -y && apt-get install -y \
  wireguard-tools="${WIREGUARD_TOOLS_VERSION}" \
  iproute2="${IPROUTE2_VERSION}" \
  nftables="${NFTABLES_VERSION}" \
  tini="${TINI_VERSION}" \
  sudo="${SUDO_VERSION}" \
  ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN groupadd --gid 1001 wireguard \
  && useradd --uid 1001 --gid 1001 --create-home --shell /usr/sbin/nologin wireguard \
  && echo 'wireguard ALL=(root) NOPASSWD: /usr/bin/wg-quick' > /etc/sudoers.d/wireguard \
  && chmod 0440 /etc/sudoers.d/wireguard

RUN mkdir -p /etc/wireguard /run/wireguard /wireguard-bin \
  && chown -R 1001:1001 /etc/wireguard /run/wireguard /wireguard-bin \
  && chmod 0755 /etc/wireguard

COPY entrypoint.sh /entrypoint.sh

RUN chmod 0755 /entrypoint.sh

USER wireguard

EXPOSE 51820/udp

WORKDIR /wireguard-bin

ENTRYPOINT ["/usr/bin/tini", "--", "/entrypoint.sh"]
