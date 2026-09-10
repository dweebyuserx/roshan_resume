#!/usr/bin/env bash
set -e

# ---------------------------------------------------------------------------
# Build script — injects analytics tokens from environment variables.
# Tokens are substituted into placeholder strings in the HTML files.
#
# Required env vars:
#   CF_ANALYTICS_TOKEN   — Cloudflare Web Analytics site token
#   CLARITY_ID           — Microsoft Clarity project ID
#
# Cloudflare Pages: Settings → Environment Variables → add both vars there.
# Local dev:        cp .env.example .env → fill in values → source .env && bash build.sh
# ---------------------------------------------------------------------------

if [ -z "$CF_ANALYTICS_TOKEN" ] || [ -z "$CLARITY_ID" ]; then
  echo "ERROR: CF_ANALYTICS_TOKEN and CLARITY_ID must be set." >&2
  echo "  Copy .env.example → .env, fill in values, then: source .env && bash build.sh" >&2
  exit 1
fi

HTML_FILES="index.html about.html projects.html articles.html connect.html"

for f in $HTML_FILES; do
  sed -i "s/CLOUDFLARE_TOKEN_HERE/${CF_ANALYTICS_TOKEN}/g" "$f"
  sed -i "s/CLARITY_ID_HERE/${CLARITY_ID}/g" "$f"
  echo "  [ok] $f"
done

echo "Build complete — tokens injected into all pages."
