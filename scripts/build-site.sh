#!/bin/sh
# Builds the demo site into dist/. Asset paths are relative, so it works under /<repo>/.
set -e
cd "$(dirname "$0")/.."
gleam run -m lustre/dev build xeerpe_dev
sed -i.bak 's|src="/|src="./|g; s|href="/|href="./|g' dist/index.html && rm dist/index.html.bak
