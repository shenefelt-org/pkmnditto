#!/usr/bin/env bash
set -euo pipefail

curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker "$USER"

echo "Docker installed. Log out and back in for group membership to take effect."
