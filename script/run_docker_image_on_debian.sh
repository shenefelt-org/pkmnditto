#!/usr/bin/env bash
set -euo pipefail

image_ref="${IMAGE_REF:-ghcr.io/shenefelt-org/pkmnditto:latest}"

if [[ "$image_ref" == ghcr.io/* ]]; then
  echo "Pulling ${image_ref} ..."
  if ! docker pull "$image_ref"; then
    local_image="pkmnditto:latest"

    if docker image inspect "$local_image" >/dev/null 2>&1; then
      echo "WARNING: Could not pull ${image_ref}. Falling back to local image ${local_image}." >&2
      echo "Set IMAGE_REF explicitly if you want to run a different image." >&2
      image_ref="$local_image"
    else
      cat >&2 <<EOF
ERROR: Could not pull ${image_ref}.

The GHCR image may not exist yet, may be private, or may require 'docker login ghcr.io'.
Build a local image first with script/build_docker_img_on_debian.sh, or set IMAGE_REF=pkmnditto:latest.
EOF
      exit 1
    fi
  fi
fi

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
  "$image_ref"
