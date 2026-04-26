#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/shenefelt-org/pkmnditto.git
cd pkmnditto

echo "SECRET_KEY_BASE=" > .env
echo ".env created — fill in SECRET_KEY_BASE before running the app."

chmod +x script/*.sh
