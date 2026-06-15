// IG-50 safe: external signal re-validated locally
const express = require('express');
const { checkLicense } = require('vendor-license-sdk');
const { verifyAdminEntitlement } = require('./policy');
const app = express();

app.post('/grant', async (req, res) => {
  const result = await checkLicense(req.body.key);
  if (result.valid && verifyAdminEntitlement(req.user.id, req.body.key)) {
    req.session.isAdmin = true;
    return res.json({ granted: true });
  }
  res.status(403).json({ granted: false });
});

module.exports = app;
