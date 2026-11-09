#!/usr/bin/env bash
# Builds ./dist (the ONLY directory Cloudflare Pages should publish).
# Allowlist copy: internal docs, CLAUDE.md, build.sh, .env* never ship.
# Env: CF_ANALYTICS_TOKEN (alphanumeric only).
set -euo pipefail

: "${CF_ANALYTICS_TOKEN:?set CF_ANALYTICS_TOKEN}"
re='^[A-Za-z0-9]+$'
[[ $CF_ANALYTICS_TOKEN =~ $re ]] || { echo "ERROR: tokens must be alphanumeric" >&2; exit 1; }

rm -rf dist && mkdir dist
cp index.html about.html projects.html articles.html connect.html _headers roshan-abraham-cv.pdf dist/
cp -r assets dist/assets

for f in dist/*.html; do
  sed -i "s/CLOUDFLARE_TOKEN_HERE/${CF_ANALYTICS_TOKEN}/g" "$f"
done
if grep -l "_HERE" dist/*.html; then echo "ERROR: placeholder left in output" >&2; exit 1; fi
echo "dist/ ready: $(ls dist | wc -l) entries"
