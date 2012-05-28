module.exports = function() {};
var log = require('log4js').getLogger();
var child_process = require('child_process');
var _ = require('underscore');

// --------------------------------------------------------------------------------------------------------------------------------------------------------
//
//  Spawn a command line process, and stream the feedback back to the calling client
//
// =========================================================================================================================================================

child_process.spawn = _.wrap(child_process.spawn, function(func) {
  // We have to strip arguments[0] out, because that is the function
  // actually being wrapped. Unfortunately, 'arguments' is no real array,
  // so shift() won't work. That's why we have to use Array.prototype.splice 
  // or loop over the arguments. Of course splice is cleaner. Thx to Ryan
  // McGrath for this optimization.
  var args = Array.prototype.slice.call(arguments, 0);

  log.debug('calling cli command with args: '+args);

  // Call the wrapped function with our now cleaned args array
  //TODO: Fix why apply() doesn't work
  var childProcess = func.apply(this, args);

  childProcess.stdout.on('data', function(data) {
    process.stdout.write('' + data);
  });

  childProcess.stderr.on('data', function(data) {
    process.stderr.write('' + data);
  });

  return childProcess;
});

// execute the following cmds on the appropriate server (note this is also for container management - need to duplicate this for container level)
module.exports.spawn_command = function(server, cmd, args) {

	  //TODO: connect to the server
	  // ....
	  log.debug('spawn cli cmd: ' + cmd + " " + args);

	  // run the command
	  var child = child_process.spawn( cmd, args, 
		function (error, stdout, stderr) {
			log.debug('stdout: ' + stdout);
			log.debug('stderr: ' + stderr);
			if (error !== null) {
				log.debug('returning error');
				log.debug('exec error: ' + error);
				return error;
			} else {
				log.debug('returning stdout');
			}
		});

		return child;
}

// execute the following cmds on the appropriate server (note this is also for container management - need to duplicate this for container level)
module.exports.execute_command = function(callback, server, cmd, args) {

	//TODO: connect to the server
	// ....

	var full_cmd = cmd + " " + args.join(' ');
	log.debug('execute cli cmd: ' + full_cmd);

	// run the command
	var child = child_process.exec( full_cmd, function (error, stdout, stderr) {
		log.debug('stdout: ' + stdout);
		log.debug('stderr: ' + stderr);
		if (error !== null) {
			log.debug('returning error');
			log.debug('exec error: ' + error);
			callback(error+stderr);
		} else {
			log.debug('returning stdout');
			callback(stdout);
		}
	});
	return child;
}

// Execute a command and stream the results back to the requester, also shut down the command when the client disconnects
module.exports.call_cli = function(req, res, next) {

  //TODO: connect to server
//  if( req.params.server != null ) {  }

  var tail_child = execute_command( localhost, req.params.cmd, req.params.args.split(' '), {
  	cwd: '.' || req.params.workingdir
  });

  tail_child.stdout.on('data', function(data) {
  	res.send('' + data);	
  });
}
