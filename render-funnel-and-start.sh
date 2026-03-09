#!/bin/sh
set -eu

if [ -z "${TS_DOMAIN:-}" ]; then
  echo "TS_DOMAIN is required" >&2
  exit 1
fi

mkdir -p /config

sed "s|\${TS_DOMAIN}|${TS_DOMAIN}|g" \
  /templates/funnel.json.template > /config/funnel.json

exec /usr/local/bin/containerboot
