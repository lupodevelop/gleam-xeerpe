#!/bin/sh
# Bundles a xeerpe release into this package: scripts/update-xeerpe.sh [version]
set -e
cd "$(dirname "$0")/.."

npm install --save-exact "xeerpe@${1:-latest}"
version=$(node -p 'require("./node_modules/xeerpe/package.json").version')

cp node_modules/xeerpe/dist/index.mjs src/xeerpe_vendor/xeerpe.mjs
cp node_modules/xeerpe/LICENSE src/xeerpe_vendor/LICENSE
echo "xeerpe@$version (npm, MIT). Update with scripts/update-xeerpe.sh." > src/xeerpe_vendor/VERSION
sed -i.bak "s/^pub const bundled_version = \".*\"/pub const bundled_version = \"$version\"/" src/xeerpe.gleam
rm src/xeerpe.gleam.bak
sed -i.bak "s|<!--v-->[^<]*<!--/v-->|<!--v-->$version<!--/v-->|g" README.md
rm README.md.bak

gleam test
echo "bundled xeerpe $version"
