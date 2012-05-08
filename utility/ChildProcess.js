child_process.spawn = underscore.wrap(child_process.spawn, function(func) {
  // We have to strip arguments[0] out, because that is the function
  // actually being wrapped. Unfortunately, 'arguments' is no real array,
  // so shift() won't work. That's why we have to use Array.prototype.splice 
  // or loop over the arguments. Of course splice is cleaner. Thx to Ryan
  // McGrath for this optimization.
  Array.prototype.splice.call(arguments, 0, 1);
  // Call the wrapped function with our now cleaned args array
  var childProcess = func.apply(this, args);

  childProcess.stdout.on('data', function(data) {
    process.stdout.write('' + data);
  });

  childProcess.stderr.on('data', function(data) {
    process.stderr.write('' + data);
  });

  return childProcess;
});




