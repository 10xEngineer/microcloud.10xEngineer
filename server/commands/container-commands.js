module.exports = function() {};

module.exports.create = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var containerCount = pool.containerCount(server);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-ubuntu',
			args: '-p /mnt/vm' + (containerCount+1) + ' -n vm' + (containerCount+1)
		}]
	});
    res.send('' + result);
}

module.exports.delete = function(req, res, next) {
	res.send('container_delete NOT IMPLEMENTED');
}

module.exports.clone = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var containerCount = pool.containerCount(server);
	var result = execute_command(server, {
		commands: [{
			command: 'cp',
			args: '-r /mnt/vm' + req.params.container + ' /mnt/vm' + (containerCount+1)
		},
		{
			command: 'lxc-create',
			args: '-n /mnt/vm' + (containerCount+1) + ' -f /mnt/vm' + (containerCount+1) + '/config'	
		}]
	});
    res.send('' + result);
}

module.exports.start = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var containerCount = pool.containerCount(server);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-start',
			args: '-n vm' + (containerCount+1) + ' -d'
		}]
	});
    res.send('' + result);
}

module.exports.stop = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-stop',
			args: '-n vm' + req.params.container
		}]
	});
    res.send('' + result);
}

module.exports.info = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-info',
			args: '-n vm' + req.params.container
		}]
	});
    res.send('' + result);
}

module.exports.save = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-freeze',
			args: '-n vm' + req.params.container
		}]
	});
    res.send('' + result);
}

module.exports.restore = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-unfreeze',
			args: '-n vm' + req.params.container
		}]
	});
    res.send('' + result);
}

module.exports.init = function(req, res, next) {
	res.send('container_init NOT IMPLEMENTED');
}

module.exports.exposeservice = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'iptables',
			args: '-t nat -A PREROUTING -p tcp --dport ' + req.params.port + ' -j DNAT --to-destination vm' + req.params.container + ':' + req.params.internalport
		}]
	});
    res.send('' + result);
}

module.exports.setcpulimit = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc.cgroup.cpu.shares',
			args: '' + (req.params.cpushare * 1024)
		}]
	});
    res.send('' + result);
}

module.exports.setcpuaffinity = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc.cgroup.cpuset.cpus',
			args: '' + (req.params.cpus * 1024)
		}]
	});
    res.send('' + result);
}

module.exports.setramlimit = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc.cgroup.memory.limit_in_bytes',
			args: '' + (req.params.ram) // e.g. 256M 
		}]
	});
    res.send('' + result);
}

module.exports.setswaplimit = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc.cgroup.memory.memsw.limit_in_bytes',
			args: '' + (req.params.swap) // e.g. 1G
		}]
	});
    res.send('' + result);
}

module.exports.setfilelimit = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var file = 'vm' + req.params.container + '.img';
	var result = execute_command(server, {
		commands: [{
			command: 'dd',
			args:  'if=/dev/zero of=' + file 
				+ ' bs=' + req.params.filesize + ' count=1' 
				+ ' && mkfs.ext3 ' + file 
				+ ' && mount -o loop ' + file
				+ ' /mnt/vm' + req.params.container + '/rootfs'
		}]
	});
    res.send('' + result);
}

module.exports.setnetworklimit = function(req, res, next) {
	res.send('container_setnetworklimit NOT IMPLEMENTED');
	/*
	to limit network bandwidth per container, you'll want to use the tc utility.
	Keep in mind you'll need to use separate bridges (br0, br1) for each container if you go this route.
	Don't forget to edit the config of each VM to match your new bridge if you do so.
	*/
}