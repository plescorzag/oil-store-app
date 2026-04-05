const express = require("express");
const path = require("path");

const app = express();
const port = process.env.PORT || 8080;

const SAME_NS_URL = process.env.SAME_NS_URL || "http://oil-same-ns:8080/health";
const OTHER_NS_URL = process.env.OTHER_NS_URL || "http://oil-other-ns.oil-peer.svc.cluster.local:8080/health";
const BLOCKED_NS_URL = process.env.BLOCKED_NS_URL || "http://oil-blocked.oil-blocked.svc.cluster.local:8080/health";

const EXTERNAL_FAST_URL = process.env.EXTERNAL_FAST_URL || "https://www.redhat.com";
const EXTERNAL_SLOW_URL = process.env.EXTERNAL_SLOW_URL || "https://httpbin.org/delay/5";
const EXTERNAL_MISSING_URL = process.env.EXTERNAL_MISSING_URL || "https://does-not-exist.invalid";

const essences = [
  { name: "Lavender Bloom", note: "Floral", price: 14.0 },
  { name: "Cedar Mist", note: "Woody", price: 15.5 },
  { name: "Golden Citrus", note: "Bright", price: 12.0 },
  { name: "Velvet Patchouli", note: "Earthy", price: 18.0 },
  { name: "Mint Air", note: "Fresh", price: 11.0 },
  { name: "Warm Vanilla", note: "Soft", price: 17.0 },
  { name: "Forest Cypress", note: "Green", price: 13.5 },
  { name: "Amber Frankincense", note: "Resin", price: 19.0 },
  { name: "Rose Garden", note: "Elegant", price: 18.5 },
  { name: "Bergamot Sun", note: "Citrus", price: 12.5 },
  { name: "Tea Tree Pure", note: "Clean", price: 13.0 },
  { name: "Ylang Calm", note: "Exotic", price: 16.0 },
  { name: "Neroli Light", note: "Fresh floral", price: 18.0 },
  { name: "Sandal Silk", note: "Creamy wood", price: 21.0 },
  { name: "Juniper Trail", note: "Cool wood", price: 14.5 },
  { name: "Lime Spark", note: "Sharp citrus", price: 11.5 },
  { name: "Chamomile Soft", note: "Gentle", price: 13.5 },
  { name: "Basil Breeze", note: "Herbal", price: 12.5 },
  { name: "Cardamom Glow", note: "Spice", price: 16.5 },
  { name: "Vetiver Deep", note: "Grounded", price: 19.5 }
];

app.use(express.static(path.join(__dirname, "public")));

app.get("/api/catalog", (_req, res) => {
  res.json({ count: essences.length, items: essences });
});

async function probe(url) {
  const started = Date.now();
  try {
    const response = await fetch(url, { redirect: "follow" });
    const text = await response.text();
    return {
      ok: response.ok,
      status: response.status,
      elapsedMs: Date.now() - started,
      url,
      body: text.slice(0, 250)
    };
  } catch (err) {
    return {
      ok: false,
      status: 0,
      elapsedMs: Date.now() - started,
      url,
      error: err.message
    };
  }
}

app.get("/api/test/fast-external", async (_req, res) => res.json(await probe(EXTERNAL_FAST_URL)));
app.get("/api/test/slow-external", async (_req, res) => res.json(await probe(EXTERNAL_SLOW_URL)));
app.get("/api/test/missing-external", async (_req, res) => res.json(await probe(EXTERNAL_MISSING_URL)));
app.get("/api/test/same-namespace", async (_req, res) => res.json(await probe(SAME_NS_URL)));
app.get("/api/test/other-namespace", async (_req, res) => res.json(await probe(OTHER_NS_URL)));
app.get("/api/test/blocked-namespace", async (_req, res) => res.json(await probe(BLOCKED_NS_URL)));

app.listen(port, () => {
  console.log(`oil-essence-web listening on ${port}`);
});
