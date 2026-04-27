#!/usr/bin/env bash

repo_url=
revision="$(git rev-parse --short=12 HEAD)"
created="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
version="$revision"

docker build \
  --build-arg IMAGE_SOURCE="https://github.com/shenefelt-org/pkmnditto" \
  --build-arg IMAGE_URL="https://github.com/shenefelt-org/pkmnditto" \
  --build-arg IMAGE_REVISION="$(git rev-parse --short=12 HEAD)" \
  --build-arg IMAGE_CREATED="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --build-arg IMAGE_VERSION="$(git rev-parse --short=12 HEAD)"\
  -t pkmnditto:latest \
  -t ghcr.io/shenefelt-org/pkmnditto:latest \
  .


docker push ghcr.io/shenefelt-org/pkmnditto:latest

