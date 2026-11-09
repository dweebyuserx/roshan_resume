# expdweeb.com

Static portfolio (5 HTML pages, no frameworks). Built by `build.sh` into `dist/` and served by
Cloudflare Pages. Analytics IDs are injected from environment variables at build time — never commit secrets.

    CF_ANALYTICS_TOKEN=… bash build.sh   # outputs ./dist
