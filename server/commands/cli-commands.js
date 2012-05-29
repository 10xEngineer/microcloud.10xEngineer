(function() {
  var child_process, log, _;

  module.exports = function() {};

  log = require("log4js").getLogger();

  child_process = require("child_process");

  _ = require("underscore");

  child_process.spawn = _.wrap(child_process.spawn, function(func) {
    var args, childProcess;
    args = Array.prototype.slice.call(arguments, 0);
    log.debug("calling cli command with args: " + args);
    childProcess = func.apply(this, args);
    childProcess.stdout.on("data", function(data) {
      return process.stdout.write("" + data);
    });
    childProcess.stderr.on("data", function(data) {
      return process.stderr.write("" + data);
    });
    return childProcess;
  });

  module.exports.spawn_command = function(server, cmd, args) {
    var child;
    log.debug("spawn cli cmd: " + cmd + " " + args);
    child = child_process.spawn(cmd, args, function(error, stdout, stderr) {
      log.debug("stdout: " + stdout);
      log.debug("stderr: " + stderr);
      if (error !== null) {
        log.debug("returning error");
        log.debug("exec error: " + error);
        return error;
      } else {
        return log.debug("returning stdout");
      }
    });
    return child;
  };

  module.exports.execute_command = function(server, cmd, args, callback) {
    var child, full_cmd;
    full_cmd = cmd + " " + args.join(" ");
    log.debug("execute cli cmd: " + full_cmd);
    child = child_process.exec(full_cmd, function(error, stdout, stderr) {
      log.debug("stdout: " + stdout);
      log.debug("stderr: " + stderr);
      if (error !== null) {
        log.debug("returning error");
        log.debug("exec error: " + error);
        return callback(error + stderr);
      } else {
        log.debug("returning stdout");
        return callback(stdout);
      }
    });
    return child;
  };

  module.exports.call_cli = function(req, res, next) {
    var tail_child;
    tail_child = execute_command(localhost, req.params.cmd, req.params.args.split(" "), {
      cwd: "." || req.params.workingdir
    }, function(output) {
      return res.send(output);
    });
    return tail_child.stdout.on("data", function(data) {
      return res.send("" + data);
    });
  };

}).call(this);
