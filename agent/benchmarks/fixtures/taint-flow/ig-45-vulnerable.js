// IG-45 vulnerable: user input → SQL without parameterization
const express = require('express');
const db = require('./db');
const app = express();

app.get('/user', (req, res) => {
  const id = req.query.id;
  const query = 'SELECT * FROM users WHERE id = ' + id;
  db.raw(query).then(rows => res.json(rows));
});

module.exports = app;
