// IG-45 safe: parameterized query
const express = require('express');
const db = require('./db');
const app = express();

app.get('/user', (req, res) => {
  const id = req.query.id;
  db.query('SELECT * FROM users WHERE id = ?', [id]).then(rows => res.json(rows));
});

module.exports = app;
