module.exports = function() {};
var log = require('log4js').getLogger();
var commands = require('./commands');

//==================================================================================================================================
module.exports.start = function(req, res, next) {
	log.info('starting a server on : ' + req.params.destination);
	var child = commands.cli.execute_command( 'localhost', './scripts/startserver.sh', [req.params.destination], function(output) {
		res.send(output);
	} );
	
	child.stdout.on('data', function(data) {
		//res.send(data);
		log.debug(data);
	});

	child.stderr.on('data', function(data) {
		//res.send(data);
		log.debug(data);
	});
	
	child.on('exit', function(code) {
		log.debug('exiting startserver.sh');
		child.stdin.end();
	});
	
	return next();
}

//==================================================================================================================================
module.exports.stop = function(req, res, next) {
	log.info('stopping a server ' + req.params.server + ' on : ' + req.params.destination);
	var child = commands.cli.execute_command( 'localhost', './scripts/stopserver.sh', [req.params.destination], function(output) {
		res.send(output);
	} );
	
	child.stdout.on('data', function(data) {
		//res.send(data);
		log.debug(data);
	});

	child.stderr.on('data', function(data) {
		//res.send(data);
		log.debug(data);
	});
	
	child.on('exit', function(code) {
		log.debug('exiting stopserver.sh');
		child.stdin.end();
	});
	
	return next();
}

//==================================================================================================================================
module.exports.status = function(req, res, next) {
	log.info('stopping a server ' + req.params.server + ' on : ' + req.params.destination);
	var child = commands.cli.execute_command( 'localhost', './scripts/getstatusserver.sh', [req.params.destination], function(output) {
		res.send(output);
	} );
	
	child.stdout.on('data', function(data) {
		//res.send(data);
		log.debug(data);
	});

	child.stderr.on('data', function(data) {
		//res.send(data);
		log.debug(data);
	});
	
	child.on('exit', function(code) {
		log.debug('exiting stopserver.sh');
		child.stdin.end();
	});
	
	return next();
}

//==================================================================================================================================
module.exports.restart = function(req, res, next) {
	log.info('restarting a server ' + req.params.server + ' on : ' + req.params.destination);
	var child = commands.cli.execute_command( 'localhost', './scripts/restartserver.sh', [req.params.destination] );
	
	child.stdout.on('data', function(data) {
		//res.send(data);
		log.debug(data);
	});

	child.stderr.on('data', function(data) {
		//res.send(data);
		log.debug(data);
	});
	
	child.on('exit', function(code) {
		log.debug('exiting stopserver.sh');
		child.stdin.end();
	});
	
	return next();
}
