/**
 * Start the Express server on port 3000. Run npm start from this directory
 * so the static middleware can find express/ relative to the working
 * directory. Requests that fall through the static middleware receive
 * express/index.html. The page's script.js handles conversion in the browser.
 */
const http = require('http');
const express = require('express');
const path = require('path');
const app = express();

app.use(express.json());
app.use(express.static("express"));

app.use('/', function(req, res) {
    res.sendFile(path.join(__dirname + '/express/index.html'));

});

const server = http.createServer(app);
const port = 3000;

server.listen(port);
console.debug('Server listening on port ' + port);
