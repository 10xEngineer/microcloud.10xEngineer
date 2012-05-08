module.exports = function() {};

var child_process = require('child_process');
var underscore = require('underscore');

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

// execute the following cmds on the appropriate server (note this is for container management - need to duplicate this for container level)
function execute_command(server, cmd, args) {
  // connect to the server
  // ....

  // run the command
  var tail_child = child_process.spawn(cmd, args.split(' '), {
  	cwd: '.'
  });

  tail_child.stdout.on('data', function(data) {
  	return ('' + data);	
  });
}

// Execute a command and stream the results back to the requester, also shut down the command when the client disconnects
module.exports.respond = function(req, res, next) {
  var tail_child = child_process.spawn(req.params.cmd, req.params.args.split(' '), {
  	cwd: '.'
  });

  tail_child.stdout.on('data', function(data) {
  	res.send('' + data);	
  });
}

module.exports.pool_status = function(req, res, next) {
	res.send('pool_status NOT IMPLEMENTED');
}

module.exports.pool_startup = function(req, res, next) {
	res.send('pool_startup NOT IMPLEMENTED');
}

module.exports.pool_shutdown = function(req, res, next) {
	res.send('pool_shutdown NOT IMPLEMENTED');
}

module.exports.pool_addserver = function(req, res, next) {
	res.send('pool_addserver NOT IMPLEMENTED');
}

module.exports.pool_removeserver = function(req, res, next) {
	res.send('pool_removeserver NOT IMPLEMENTED');
}

module.exports.pool_allocate = function(req, res, next) {
	res.send('pool_allocate NOT IMPLEMENTED');
}

module.exports.pool_deallocate = function(req, res, next) {
	res.send('pool_deallocate NOT IMPLEMENTED');
}

module.exports.server_start = function(req, res, next) {
	res.send('server_start NOT IMPLEMENTED');
}

module.exports.server_stop = function(req, res, next) {
	res.send('server_stop NOT IMPLEMENTED');
}

module.exports.server_status = function(req, res, next) {
	res.send('server_status NOT IMPLEMENTED');
}

module.exports.server_restart = function(req, res, next) {
	res.send('server_restart NOT IMPLEMENTED');
}

module.exports.container_create = function(req, res, next) {
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

module.exports.container_delete = function(req, res, next) {
	res.send('container_delete NOT IMPLEMENTED');
}

module.exports.container_clone = function(req, res, next) {
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

module.exports.container_start = function(req, res, next) {
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

module.exports.container_stop = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-stop',
			args: '-n vm' + req.params.container
		}]
	});
    res.send('' + result);
}

module.exports.container_info = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-info',
			args: '-n vm' + req.params.container
		}]
	});
    res.send('' + result);
}

module.exports.container_save = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-freeze',
			args: '-n vm' + req.params.container
		}]
	});
    res.send('' + result);
}

module.exports.container_restore = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc-unfreeze',
			args: '-n vm' + req.params.container
		}]
	});
    res.send('' + result);
}

module.exports.container_init = function(req, res, next) {
	res.send('container_init NOT IMPLEMENTED');
}

module.exports.container_exposeservice = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'iptables',
			args: '-t nat -A PREROUTING -p tcp --dport ' + req.params.port + ' -j DNAT --to-destination vm' + req.params.container + ':' + req.params.internalport
		}]
	});
    res.send('' + result);
}

module.exports.container_setcpulimit = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc.cgroup.cpu.shares',
			args: '' + (req.params.cpushare * 1024)
		}]
	});
    res.send('' + result);
}

module.exports.container_setcpuaffinity = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc.cgroup.cpuset.cpus',
			args: '' + (req.params.cpus * 1024)
		}]
	});
    res.send('' + result);
}

module.exports.container_setramlimit = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc.cgroup.memory.limit_in_bytes',
			args: '' + (req.params.ram) // e.g. 256M 
		}]
	});
    res.send('' + result);
}

module.exports.container_setswaplimit = function(req, res, next) {
	var server = pool.findServerFromContainer(req.params.container);
	var result = execute_command(server, {
		commands: [{
			command: 'lxc.cgroup.memory.memsw.limit_in_bytes',
			args: '' + (req.params.swap) // e.g. 1G
		}]
	});
    res.send('' + result);
}

module.exports.container_setfilelimit = function(req, res, next) {
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

module.exports.container_setnetworklimit = function(req, res, next) {
	res.send('container_setnetworklimit NOT IMPLEMENTED');
	/*
	to limit network bandwidth per container, you'll want to use the tc utility.
	Keep in mind you'll need to use separate bridges (br0, br1) for each container if you go this route.
	Don't forget to edit the config of each VM to match your new bridge if you do so.
	*/
}