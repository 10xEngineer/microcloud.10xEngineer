(function() {

  child_process.spawn = underscore.wrap(child_process.spawn, function(func) {
    var childProcess;
    Array.prototype.splice.call(arguments, 0, 1);
    childProcess = func.apply(this, args);
    childProcess.stdout.on("data", function(data) {
      return process.stdout.write("" + data);
    });
    childProcess.stderr.on("data", function(data) {
      return process.stderr.write("" + data);
    });
    return childProcess;
  });

}).call(this);
