#!/usr/bin/env bash
set -euo pipefail

git clone https://github.com/shenefelt-org/pkmnditto.git
cd pkmnditto

echo "SECRET_KEY_BASE=42bcde4475bb7012f85375888c4fb6418e4666795d58f3e5bfd55838fd54a76a8be1be4c3a981aa1ccc8b98d62decbbdaed6882b324e2cad3cb00d3e9b18538a" > .env
echo ".env created with SECRET_KEY_BASE."

chmod +x script/*.sh
