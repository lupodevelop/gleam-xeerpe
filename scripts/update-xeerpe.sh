#!/bin/sh
# Bundles a xeerpe release into this package: scripts/update-xeerpe.sh [version]
set -e
cd "$(dirname "$0")/.."

npm install --prefix test/npm-xeerpe --save-exact "xeerpe@${1:-latest}"
version=$(node -p 'require("./test/npm-xeerpe/node_modules/xeerpe/package.json").version')

cp test/npm-xeerpe/node_modules/xeerpe/dist/index.mjs src/xeerpe_vendor/xeerpe.mjs
cp test/npm-xeerpe/node_modules/xeerpe/LICENSE src/xeerpe_vendor/LICENSE
echo "xeerpe@$version (npm, MIT). Update with scripts/update-xeerpe.sh." > src/xeerpe_vendor/VERSION
sed -i.bak "s/^pub const bundled_version = \".*\"/pub const bundled_version = \"$version\"/" src/xeerpe.gleam
rm src/xeerpe.gleam.bak
# css.keyframes is animations.css as a Gleam string, the last thing in css.gleam
node -e '
const fs = require("fs");
const css = fs.readFileSync("test/npm-xeerpe/node_modules/xeerpe/dist/animations.css", "utf8").trim();
if (/["\\]/.test(css)) throw new Error("animations.css needs escaping now");
const file = "src/xeerpe/css.gleam";
const src = fs.readFileSync(file, "utf8");
const at = src.indexOf("pub const keyframes = \"");
if (at < 0) throw new Error("keyframes not found in " + file);
fs.writeFileSync(file, src.slice(0, at) + "pub const keyframes = \"" + css + "\"\n");
'
sed -i.bak "s|<!--v-->[^<]*<!--/v-->|<!--v-->$version<!--/v-->|g" README.md
rm README.md.bak

gleam test
echo "bundled xeerpe $version"
