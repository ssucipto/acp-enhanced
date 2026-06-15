// IG-48 safe: redirect allowlist
const express = require('express');
const app = express();

const ALLOWED_HOSTS = new Set(['example.com', 'app.example.com']);

app.get('/go', (req, res) => {
  const target = req.query.url;
  try {
    const u = new URL(target);
    if (!ALLOWED_HOSTS.has(u.hostname)) return res.status(400).send('invalid redirect');
    res.redirect(u.toString());
  } catch {
    res.status(400).send('invalid url');
  }
});

module.exports = app;
