// IG-48 vulnerable: user input → URL redirect
const express = require('express');
const app = express();

app.get('/go', (req, res) => {
  const target = req.query.url;
  res.redirect(target);
});

module.exports = app;
