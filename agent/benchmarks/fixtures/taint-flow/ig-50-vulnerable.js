// IG-50 vulnerable: third-party output → security decision without re-validation
const express = require('express');
const { checkLicense } = require('vendor-license-sdk');
const app = express();

app.post('/grant', async (req, res) => {
  const result = await checkLicense(req.body.key);
  if (result.valid) {
    req.session.isAdmin = true;
    return res.json({ granted: true });
  }
  res.status(403).json({ granted: false });
});

module.exports = app;
