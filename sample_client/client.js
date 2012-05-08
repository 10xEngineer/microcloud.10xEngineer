var restify = require('restify');

// Creates a JSON client
var client = restify.createJsonClient({
  url: 'http://localhost:8080'
});

client.basicAuth('$login', '$password');
client.get('/command/ps/ef', function(err, req, res, obj) {
  assert.ifError(err);

  console.log(JSON.stringify(obj, null, 2));
});