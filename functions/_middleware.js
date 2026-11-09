// Records one data point per request in Workers Analytics Engine.
// No IP, no full UA, no cookies. Query via the GraphQL/SQL API (see CLOUDFLARE.md).
export async function onRequest({ request, env, next }) {
  const t0 = Date.now();
  const res = await next();
  try {
    const u = new URL(request.url);
    const cf = request.cf || {};
    const ua = request.headers.get("user-agent") || "";
    const ref = request.headers.get("referer");
    env.TRAFFIC?.writeDataPoint({
      indexes: [u.pathname.slice(0, 96)],           // sampling key
      blobs: [
        request.method,
        String(res.status),
        cf.country || "??",
        cf.colo || "??",
        ref ? new URL(ref).hostname : "direct",     // referrer host only
        /bot|crawl|spider|curl|python|wget|headless/i.test(ua) ? "bot" : "human",
        (res.headers.get("content-type") || "").split(";")[0],
        cf.httpProtocol || "",
      ],
      doubles: [Date.now() - t0, cf.botManagement?.score ?? -1],
    });
  } catch {}   // analytics must never break a response
  return res;
}
