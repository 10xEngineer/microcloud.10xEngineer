module.exports = function() {};
var commands = require('commands');

module.exports.registerRoutes = function(server) {
	// run a shell command
	server.get('/command/:cmd/:args', commands.respond);
	server.head('/command/:cmd/:args', commands.respond);

	// virtual lab VM pool management
	server.get('/pool/status', commands.pool_status);
	server.get('/pool/startup', commands.pool_startup);
	server.get('/pool/shutdown', commands.pool_shutdown);
	// add/remove an ec2 instance to the pool
	server.get('/pool/addserver', commands.pool_addserver);
	server.get('/pool/:server/remove', commands.pool_removeserver);
	// add/remove an LXC instance to the ec2 server in the pool
	server.get('/pool/:server/allocate', commands.pool_allocatecontainer);
	server.get('/pool/:server/:container/deallocate', commands.pool_deallocatecontainer);

	// (ec2) server instance verbs
	server.get('/server/:server/start', commands.server_start);
	server.get('/server/:server/stop', commands.server_stop);
	server.get('/server/:server/status', commands.server_status);
	server.get('/server/:server/restart', commands.server_restart);

	// lxc container verbs
	server.get('/containers/create', commands.container_create);
	server.get('/containers/:container/delete', commands.container_delete);
	server.get('/containers/:container/clone', commands.container_clone);
	server.get('/containers/:container/start', commands.container_start);
	server.get('/containers/:container/stop', commands.container_stop);
	server.get('/containers/:container/info', commands.container_info);
	server.get('/containers/:container/save', commands.container_save);
	server.get('/containers/:container/restore', commands.container_restore);
	// build the chef server default config using chef
	server.get('/containers/:container/init', commands.container_init);
	// (optional?) expose a service in a container through the firewall
	server.get('/containers/:container/expose-service', commands.container_exposeservice);

	// set resource limits
	server.get('/containers/:container/set-cpu-limit', commands.container_setcpulimit);
	server.get('/containers/:container/set-cpu-affinity', commands.container_setcpuaffinity);
	server.get('/containers/:container/set-ram-limit', commands.container_setramlimit);
	server.get('/containers/:container/set-swap-limit', commands.container_setswaplimit);
	server.get('/containers/:container/set-file-limit', commands.container_setfilelimit);
	server.get('/containers/:container/set-network-limit', commands.container_setnetworklimit);
}