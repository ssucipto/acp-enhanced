// IG-49 safe: environment URL validated
const express = require('express');
const app = express();

function isAllowedWebhook(url) {
  try {
    const u = new URL(url);
    return u.protocol === 'https:' && u.hostname.endsWith('.example.com');
  } catch {
    return false;
  }
}

app.get('/proxy', async (req, res) => {
  const url = process.env.WEBHOOK_URL;
  if (!isAllowedWebhook(url)) return res.status(500).send('misconfigured webhook');
  const response = await fetch(url, { method: 'POST', body: JSON.stringify(req.body) });
  res.json(await response.json());
});

module.exports = app;
