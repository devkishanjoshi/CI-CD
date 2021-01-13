'use strict';
const express = require('express');
const HOST = "0.0.0.0";
const app = express();
app.get('/', (req, res) => {
  res.send('My Project');
});
app.listen(8085, HOST);
console.log(`App started Successfully `);