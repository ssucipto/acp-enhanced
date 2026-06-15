// IG-46 safe: spawn without shell, fixed command
const { spawn } = require('child_process');
const express = require('express');
const app = express();

app.get('/ping', (req, res) => {
  const host = req.query.host;
  const child = spawn('ping', ['-c', '1', host]);
  let stdout = '';
  child.stdout.on('data', d => { stdout += d; });
  child.on('close', () => res.send(stdout));
});

module.exports = app;
