#!/bin/sh

set -eu

WG_INTERFACE="${WG_INTERFACE:-wg0}"
WG_CONFIG_PATH="${WG_CONFIG_PATH:-/etc/wireguard/${WG_INTERFACE}.conf}"
WG_PRIVATE_KEY_PATH="${WG_PRIVATE_KEY_PATH:-/etc/wireguard-secrets/privatekey}"
FINAL_CONFIG_PATH="/run/wireguard/${WG_INTERFACE}.conf"

cleanup() {
  if [ -f "${FINAL_CONFIG_PATH}" ]; then
    wg-quick down "${FINAL_CONFIG_PATH}" >/dev/null 2>&1 || true
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

  # Read the key file from within awk to avoid exposing the key
  # in shell variables or process listings (visible in /proc/PID/cmdline).
  awk -v keyfile="${WG_PRIVATE_KEY_PATH}" '
  BEGIN {
    while ((getline line < keyfile) > 0) {
      gsub(/\r/, "", line)
      key = key line
    }
    close(keyfile)
    inserted = 0
  }
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

wg-quick up "${FINAL_CONFIG_PATH}"

# Enable NAT for WireGuard clients to reach internet
echo "Setting up NAT for ${WG_INTERFACE}..."
nft add table nat
nft add chain nat postrouting '{type nat hook postrouting priority srcnat; }'
nft add rule nat postrouting oifname eth0 counter masquerade
nft add table inet filter
nft add chain inet filter forward '{type filter hook forward priority filter; }'
nft add rule inet filter forward iifname ${WG_INTERFACE} oifname eth0 counter accept
nft add rule inet filter forward iifname eth0 oifname ${WG_INTERFACE} counter accept
echo "NAT setup complete"

while true; do
  sleep 3600
done
