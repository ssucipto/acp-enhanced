// IG-47 safe: path canonicalized and allowlisted
const fs = require('fs');
const path = require('path');
const express = require('express');
const app = express();

const ALLOWED = new Set(['readme.txt', 'license.txt']);

app.get('/file', (req, res) => {
  const name = req.query.name;
  if (!ALLOWED.has(name)) return res.status(403).send('forbidden');
  const base = path.resolve('/data/uploads');
  const filePath = path.resolve(base, name);
  if (!filePath.startsWith(base + path.sep)) return res.status(403).send('forbidden');
  fs.readFile(filePath, 'utf8', (err, data) => {
    if (err) return res.status(404).send('not found');
    res.send(data);
  });
});

module.exports = app;
