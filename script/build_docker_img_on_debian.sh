#!/usr/bin/env bash
set -euo pipefail

repo_url="https://github.com/shenefelt-org/pkmnditto"
revision="$(git rev-parse --short=12 HEAD)"
created="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
version="$revision"

docker build \
  --build-arg IMAGE_SOURCE="$repo_url" \
  --build-arg IMAGE_URL="$repo_url" \
  --build-arg IMAGE_REVISION="$revision" \
  --build-arg IMAGE_CREATED="$created" \
  --build-arg IMAGE_VERSION="$version" \
  -t pkmnditto:latest \
  -t ghcr.io/shenefelt-org/pkmnditto:latest \
  .

echo "Build succeeded. Pushing ghcr.io/shenefelt-org/pkmnditto:latest ..."
docker push ghcr.io/shenefelt-org/pkmnditto:latest

echo "Push succeeded. Revision: $revision"
