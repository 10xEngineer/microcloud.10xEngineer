module.exports = function() {};
var server = require('./server');
var commands = require('./commands/commands');

module.exports.registerRoutes = function(server) {
	server.get('/ping', commands.get_ping);
	server.post('/ping', commands.post_ping);
	server.get('/command/exectest', commands.test_cli_exec); 
	// spawn (for tail ... etc streaming still doesn't work)
	//server.get('/command/spawntest', commands.test_cli_spawn);
	// run a shell command
	server.get('/command/:cmd/:args', commands.cli.call_cli);
	server.head('/command/:cmd/:args', commands.cli.call_cli);

	// virtual lab VM pool management
	server.get('/pool/status', commands.pool.status);
	server.get('/pool/startup', commands.pool.startup);
	server.get('/pool/shutdown', commands.pool.shutdown);
	// add/remove an ec2 instance to the pool
	server.get('/pool/addserver', commands.pool.addserver);
	server.get('/pool/:server/remove', commands.pool.removeserver);
	// add/remove an LXC instance to the ec2 server in the pool
	server.get('/pool/:server/allocate', commands.pool.allocate);
	server.get('/pool/:server/:container/deallocate', commands.pool.deallocate);

	// (ec2) server instance verbs
	server.get('/server/start/:destination', commands.server.start);
	server.get('/server/stop/:destination/:server', commands.server.stop);
	server.get('/server/stop/:destination', commands.server.stop);
	server.get('/server/status/:destination/:server', commands.server.status);
	server.get('/server/status/:destination', commands.server.status);
	server.get('/server/restart/:destination/:server', commands.server.restart);
	server.get('/server/restart/:destination', commands.server.restart);

	// lxc container verbs
	server.get('/containers/create', commands.container.create);
	server.get('/containers/:container/delete', commands.container.delete);
	server.get('/containers/:container/clone', commands.container.clone);
	server.get('/containers/:container/start', commands.container.start);
	server.get('/containers/:container/stop', commands.container.stop);
	server.get('/containers/:container/info', commands.container.info);
	server.get('/containers/:container/save', commands.container.save);
	server.get('/containers/:container/restore', commands.container.restore);
	// build the chef server default config using chef
	server.get('/containers/:container/init', commands.container.init);
	// (optional?) expose a service in a container through the firewall
	server.get('/containers/:container/expose-service', commands.container.exposeservice);

	// set resource limits
	server.get('/containers/:container/set-cpu-limit', commands.container.setcpulimit);
	server.get('/containers/:container/set-cpu-affinity', commands.container.setcpuaffinity);
	server.get('/containers/:container/set-ram-limit', commands.container.setramlimit);
	server.get('/containers/:container/set-swap-limit', commands.container.setswaplimit);
	server.get('/containers/:container/set-file-limit', commands.container.setfilelimit);
	server.get('/containers/:container/set-network-limit', commands.container.setnetworklimit);

}