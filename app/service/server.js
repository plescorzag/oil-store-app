const express = require("express");

const app = express();
const port = process.env.PORT || 8080;
const SERVICE_NAME = process.env.SERVICE_NAME || "oil-demo-service";
const DELAY_MS = Number(process.env.DELAY_MS || "0");
const STATUS = Number(process.env.STATUS || "200");

app.get("/", (_req, res) => {
  res.json({
    service: SERVICE_NAME,
    ok: STATUS >= 200 && STATUS < 400
  });
});

app.get("/health", async (_req, res) => {
  if (DELAY_MS > 0) {
    await new Promise((resolve) => setTimeout(resolve, DELAY_MS));
  }
  res.status(STATUS).json({
    service: SERVICE_NAME,
    status: STATUS,
    delayMs: DELAY_MS,
    ts: new Date().toISOString()
  });
});

app.listen(port, () => {
  console.log(`${SERVICE_NAME} listening on ${port}`);
});
