// IG-47 vulnerable: user input → file path
const fs = require('fs');
const path = require('path');
const express = require('express');
const app = express();

app.get('/file', (req, res) => {
  const name = req.query.name;
  const filePath = path.join('/data/uploads', name);
  fs.readFile(filePath, 'utf8', (err, data) => {
    if (err) return res.status(404).send('not found');
    res.send(data);
  });
});

module.exports = app;
