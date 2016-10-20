'use strict';

const express = require('express');
const fs = require('fs');
const path = require('path');

// Constants
const PORT = 7000;

// App
const app = express();
// this is for static files

app.use('/static', express.static(__dirname + '/public'));

app.get('/', function (req, res) {
  var html = fs.readFileSync(path.join(__dirname, './index.html'), 'utf8')
  res.send(html)
});

app.listen(PORT);
console.log('Running on http://localhost:' + PORT);
