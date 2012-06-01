(function() {
  var log, restify, routes, server;

  restify = require("restify");

  log = require("log4js").getLogger();

  routes = require("./routes");

  server = module.exports = restify.createServer({
    name: "microcloud.10xengineer.me",
    version: "0.0.1"
  });

  server.use(restify.acceptParser(server.acceptable));

  server.use(restify.dateParser());

  server.use(restify.queryParser());

  server.use(restify.bodyParser());

  server.use(restify.throttle({
    burst: 100,
    rate: 50,
    ip: true,
    overrides: {
      "192.168.1.106": {
        rate: 0,
        burst: 0
      },
      "127.0.0.1": {
        rate: 0,
        burst: 0
      }
    }
  }));

  server.use(restify.conditionalRequest());

  routes.registerRoutes(server);

  server.listen(8080, function() {
    return console.log("%s listening at %s", server.name, server.url);
  });

  server.get({
    url: "/admin"
  }, function(req, res, next) {
    return res.render("ADMIN PAGE TO GO HERE");
  });

}).call(this);
