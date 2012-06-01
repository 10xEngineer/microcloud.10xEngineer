(function() {
  var cli, container, log, pool, server;

  module.exports.command = function() {};

  log = require("log4js").getLogger();

  cli = module.exports.cli = require("./cli-commands");

  pool = module.exports.pool = require("./pool-commands");

  server = module.exports.server = require("./server-commands");

  container = module.exports.container = require("./container-commands");

  module.exports.get_ping = function(req, res, next) {
    log.info("ping received.");
    return res.send({
      pong: true
    });
  };

  module.exports.post_ping = function(req, res, next) {
    log.info("ping _post_ received");
    return res.send(200, {}, req.data);
  };

  module.exports.test_cli_exec = function(req, res, next) {
    var child;
    log.info("running ls -l to test the cli command interface.");
    child = cli.execute_command("localhost", "ls", ["-lh", "/usr"], function(output) {
      return res.send(output);
    });
    child.stdout.on("data", function(data) {
      return res.send(data);
    });
    child.stderr.on("data", function(data) {
      return res.send(data);
    });
    child.on("exit", function(code) {
      return child.stdin.end();
    });
    return next();
  };

  module.exports.test_cli_spawn = function(req, res, next) {
    var child;
    log.info("running top to test the cli command interface.");
    child = cli.spawn_command("localhost", "top", []);
    child.stdout.on("data", function(data) {
      return res.send(data);
    });
    child.stderr.on("data", function(data) {
      return res.send(data);
    });
    child.on("exit", function(code) {
      return child.stdin.end();
    });
    return next();
  };

}).call(this);
