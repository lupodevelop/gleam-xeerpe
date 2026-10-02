#!/bin/sh
# Static site for GitHub Pages -> demo/dist. Relative asset paths so it works under /<repo>/.
set -e
cd "$(dirname "$0")"
gleam run -m lustre/dev build
sed -i.bak 's|src="/|src="./|g; s|href="/|href="./|g' dist/index.html && rm dist/index.html.bak
