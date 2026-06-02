#!/bin/sh

set -eu

WG_INTERFACE="${WG_INTERFACE:-wg0}"
WG_CONFIG_PATH="${WG_CONFIG_PATH:-/etc/wireguard/${WG_INTERFACE}.conf}"
WG_PRIVATE_KEY_PATH="${WG_PRIVATE_KEY_PATH:-/etc/wireguard-secrets/privatekey}"
FINAL_CONFIG_PATH="/run/wireguard/${WG_INTERFACE}.conf"

WG_QUICK="wg-quick"
if [ "$(id -u)" -ne 0 ]; then
  WG_QUICK="sudo -n wg-quick"
fi

cleanup() {
  if [ -f "${FINAL_CONFIG_PATH}" ]; then
    ${WG_QUICK} down "${FINAL_CONFIG_PATH}" >/dev/null 2>&1 || true
  fi
}

trap cleanup INT TERM EXIT

if [ ! -f "${WG_CONFIG_PATH}" ]; then
  echo "Missing WireGuard config at ${WG_CONFIG_PATH}" >&2
  exit 1
fi

mkdir -p /run/wireguard

if grep -Eq '^\s*PrivateKey\s*=' "${WG_CONFIG_PATH}"; then
  cp "${WG_CONFIG_PATH}" "${FINAL_CONFIG_PATH}"
else
  if [ ! -f "${WG_PRIVATE_KEY_PATH}" ]; then
    echo "WireGuard config has no PrivateKey and no key file found at ${WG_PRIVATE_KEY_PATH}" >&2
    exit 1
  fi

  WG_PRIVATE_KEY="$(tr -d '\r\n' < "${WG_PRIVATE_KEY_PATH}")"

  awk -v key="${WG_PRIVATE_KEY}" '
  BEGIN { inserted = 0 }
  /^\[Interface\]/ {
    print
    if (!inserted) {
      print "PrivateKey = " key
      inserted = 1
    }
    next
  }
  { print }
  END {
    if (!inserted) {
      print "[Interface]"
      print "PrivateKey = " key
    }
  }
  ' "${WG_CONFIG_PATH}" > "${FINAL_CONFIG_PATH}"
fi

chmod 0600 "${FINAL_CONFIG_PATH}"

${WG_QUICK} up "${FINAL_CONFIG_PATH}"

# Enable NAT for WireGuard clients to reach internet
echo "Setting up NAT for ${WG_INTERFACE}..."
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE 2>/dev/null || nft add rule nat postrouting oifname eth0 counter masquerade
iptables -A FORWARD -i ${WG_INTERFACE} -o eth0 -j ACCEPT 2>/dev/null || nft add rule inet filter forward iifname ${WG_INTERFACE} oifname eth0 counter accept
iptables -A FORWARD -i eth0 -o ${WG_INTERFACE} -j ACCEPT 2>/dev/null || nft add rule inet filter forward iifname eth0 oifname ${WG_INTERFACE} counter accept

while true; do
  sleep 3600
done
