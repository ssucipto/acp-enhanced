// IG-46 vulnerable: user input → shell command
const { exec } = require('child_process');
const express = require('express');
const app = express();

app.get('/ping', (req, res) => {
  const host = req.query.host;
  exec(`ping -c 1 ${host}`, (err, stdout) => {
    res.send(stdout || String(err));
  });
});

module.exports = app;
