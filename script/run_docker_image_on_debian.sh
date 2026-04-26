#!/usr/bin/env bash
set -euo pipefail

# Pull the latest image from GHCR
docker pull ghcr.io/shenefelt-org/pkmnditto:latest

# Load SECRET_KEY_BASE from a local .env file (same format as Windows)
if [[ ! -f .env ]]; then
  echo "ERROR: .env file not found. Create one with SECRET_KEY_BASE=<value>" >&2
  exit 1
fi

SECRET_KEY_BASE=$(grep -m1 '^SECRET_KEY_BASE=' .env | cut -d'=' -f2-)

if [[ -z "$SECRET_KEY_BASE" ]]; then
  echo "ERROR: SECRET_KEY_BASE not found in .env" >&2
  exit 1
fi

docker run --rm --name pkmnditto \
  -p 3000:80 \
  -e SECRET_KEY_BASE="$SECRET_KEY_BASE" \
  -e RAILS_ENV=production \
  -v pkmnditto_storage:/rails/storage \
  ghcr.io/shenefelt-org/pkmnditto:latest
