module.exports.command = function() {};
var log = require('log4js').getLogger();

var cli = module.exports.cli = require('./cli-commands');
var pool = module.exports.pool = require('./pool-commands');
var server = module.exports.server = require('./server-commands');
var container = module.exports.container = require('./container-commands');

// --------------------------------------------------------------------------------------------------------------------------------------------------------
//
//  Heartbeat
//
// =========================================================================================================================================================

module.exports.get_ping = function(req, res, next) {
	log.info('ping received.');
	res.send( {pong: true} );
}

module.exports.post_ping = function(req, res, next) {
	log.info('ping _post_ received');
	res.send( 200, {}, req.data );
}

// --------------------------------------------------------------------------------------------------------------------------------------------------------
//
//  Test CLI commands
//
// =========================================================================================================================================================

module.exports.test_cli_exec = function(req, res, next) {
	log.info('running ls -l to test the cli command interface.');
//	var child = cli.execute_command( 'localhost', 'ls', ['-lh', '/usr'] );
	var child = cli.execute_command( 'localhost', 'pwd', [] );
	
	child.stdout.on('data', function(data) {
		res.send(data);
	});

	child.stderr.on('data', function(data) {
		res.send(data);
	});
	
	child.on('exit', function(code) {
		child.stdin.end();
	});
	
	return next();
}

module.exports.test_cli_spawn = function(req, res, next) {
	log.info('running top to test the cli command interface.');
	var child = cli.spawn_command( 'localhost', 'top', [] );
	
	child.stdout.on('data', function(data) {
		res.send(data);
	});

	child.stderr.on('data', function(data) {
		res.send(data);
	});
	
	child.on('exit', function(code) {
		child.stdin.end();
	});
	
	return next();
}
