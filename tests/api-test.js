var APIeasy = require('api-easy'),
      assert = require('assert');

  var suite = APIeasy.describe('your/awesome/api');

  suite.discuss('When using your awesome API')
       .discuss('and your awesome resource')
       .use('localhost/ping', 8080)
       .setHeader('Content-Type', 'application/json')
       .post({ test: 'data' })
         .expect(200, { ok: true })
         .expect('should respond with x-test-header', function (err, res, body) {
           assert.include(res.headers, 'x-test-header');
         })
       .export(module);