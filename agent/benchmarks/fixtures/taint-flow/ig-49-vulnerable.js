// IG-49 vulnerable: environment variable → network without validation
const express = require('express');
const app = express();

app.get('/proxy', async (req, res) => {
  const url = process.env.WEBHOOK_URL;
  const response = await fetch(url, { method: 'POST', body: JSON.stringify(req.body) });
  res.json(await response.json());
});

module.exports = app;
