(function() {
  var commands, log;

  module.exports = function() {};

  log = require("log4js").getLogger();

  commands = require("./commands");

  module.exports.start = function(req, res, next) {
    var child;
    log.info("starting a server on : " + req.params.destination);
    child = commands.cli.execute_command("localhost", "./scripts/startserver.sh", [req.params.destination], function(output) {
      return res.send(output);
    });
    child.stdout.on("data", function(data) {
      return log.debug(data);
    });
    child.stderr.on("data", function(data) {
      return log.debug(data);
    });
    child.on("exit", function(code) {
      log.debug("exiting startserver.sh");
      return child.stdin.end();
    });
    return next();
  };

  module.exports.stop = function(req, res, next) {
    var child;
    log.info("stopping a server " + req.params.server + " on : " + req.params.destination);
    child = commands.cli.execute_command("localhost", "./scripts/stopserver.sh", [req.params.destination], function(output) {
      return res.send(output);
    });
    child.stdout.on("data", function(data) {
      return log.debug(data);
    });
    child.stderr.on("data", function(data) {
      return log.debug(data);
    });
    child.on("exit", function(code) {
      log.debug("exiting stopserver.sh");
      return child.stdin.end();
    });
    return next();
  };

  module.exports.status = function(req, res, next) {
    var child;
    log.info("stopping a server " + req.params.server + " on : " + req.params.destination);
    child = commands.cli.execute_command("localhost", "./scripts/getstatusserver.sh", [req.params.destination], function(output) {
      return res.send(output);
    });
    child.stdout.on("data", function(data) {
      return log.debug(data);
    });
    child.stderr.on("data", function(data) {
      return log.debug(data);
    });
    child.on("exit", function(code) {
      log.debug("exiting stopserver.sh");
      return child.stdin.end();
    });
    return next();
  };

  module.exports.restart = function(req, res, next) {
    var child;
    log.info("restarting a server " + req.params.server + " on : " + req.params.destination);
    child = commands.cli.execute_command("localhost", "./scripts/restartserver.sh", [req.params.destination]);
    child.stdout.on("data", function(data) {
      return log.debug(data);
    });
    child.stderr.on("data", function(data) {
      return log.debug(data);
    });
    child.on("exit", function(code) {
      log.debug("exiting stopserver.sh");
      return child.stdin.end();
    });
    return next();
  };

}).call(this);
