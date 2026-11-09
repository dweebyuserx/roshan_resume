# Cloudflare binding runbook (expdweeb.com)

1. Pages project -> Connect to Git -> build cmd `bash build.sh`, output dir `dist`.
   Env vars (Production AND Preview): CF_ANALYTICS_TOKEN, CLARITY_ID.
2. Pages -> Custom domains -> add `expdweeb.com` and `www.expdweeb.com`
   (zone must be on Cloudflare; CNAME file is GitHub-Pages-only and is ignored here).
3. Pages -> Settings -> Bindings -> Analytics Engine: binding `TRAFFIC`, dataset `portfolio_traffic`
   (wrangler.toml declares it; dashboard value must match).
4. Zone: SSL/TLS Full (strict), Always Use HTTPS, min TLS 1.2, Bot Fight Mode on.
   Web Analytics: enable for the hostname (token -> CF_ANALYTICS_TOKEN).
5. Read traffic (Analytics Engine SQL API):
   SELECT blob3 country, blob6 kind, index1 path, SUM(_sample_interval) hits
   FROM portfolio_traffic WHERE timestamp > NOW() - INTERVAL '1' DAY
   GROUP BY country, kind, path ORDER BY hits DESC LIMIT 50
