module.exports = ->

module.exports.create = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container 
	containerCount = pool.containerCount server
	result = execute_command server,
		commands: [
			command: 'lxc-ubuntu',
			args: '-p /mnt/vm' + (containerCount+1) + ' -n vm' + (containerCount+1)
		]
	, (output) ->
		res.send output

module.exports.delete = (req, res, next) ->
	res.send 'container_delete NOT IMPLEMENTED'

module.exports.clone = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	containerCount = pool.containerCount server
	result = execute_command server,
		commands: [
			command: 'cp',
			args: '-r /mnt/vm' + req.params.container + ' /mnt/vm' + (containerCount+1)
		,
			command: 'lxc-create',
			args: '-n /mnt/vm' + (containerCount+1) + ' -f /mnt/vm' + (containerCount+1) + '/config'	
		]
	, (output) ->
		res.send output

module.exports.start = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	containerCount = pool.containerCount server
	result = execute_command server,
		commands: [
			command: 'lxc-start',
			args: '-n vm' + (containerCount+1) + ' -d'
		]
	, (output) ->
		res.send output


module.exports.stop = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [
			command: 'lxc-stop',
			args: '-n vm' + req.params.container
		]
	, (output) ->
		res.send output

module.exports.info = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [
			command: 'lxc-info',
			args: '-n vm' + req.params.container
		]
	, (output) ->
		res.send output

module.exports.save = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [{
			command: 'lxc-freeze',
			args: '-n vm' + req.params.container
		}]
	, (output) ->
		res.send output

module.exports.restore = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [
			command: 'lxc-unfreeze',
			args: '-n vm' + req.params.container
		]
	, (output) ->
		res.send output

module.exports.init = (req, res, next) ->
	res.send 'container_init NOT IMPLEMENTED'


module.exports.exposeservice = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [
			command: 'iptables',
			args: '-t nat -A PREROUTING -p tcp --dport ' + req.params.port + ' -j DNAT --to-destination vm' + req.params.container + ':' + req.params.internalport
		]
	, (output) ->
		res.send output

module.exports.setcpulimit = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [
			command: 'lxc.cgroup.cpu.shares',
			args: '' + (req.params.cpushare * 1024)
		]
	, (output) ->
		res.send output

module.exports.setcpuaffinity = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [
			command: 'lxc.cgroup.cpuset.cpus',
			args: '' + (req.params.cpus * 1024)
		]
	, (output) ->
		res.send output

module.exports.setramlimit = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [
			command: 'lxc.cgroup.memory.limit_in_bytes',
			args: '' + (req.params.ram) # e.g. 256M 
		]
	, (output) ->
		res.send output

module.exports.setswaplimit = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	result = execute_command server,
		commands: [
			command: 'lxc.cgroup.memory.memsw.limit_in_bytes',
			args: '' + (req.params.swap) # e.g. 1G
		]
	, (output) ->
		res.send output

module.exports.setfilelimit = (req, res, next) ->
	server = pool.findServerFromContainer req.params.container
	file = 'vm' + req.params.container + '.img';
	result = execute_command server,
		commands: [
			command: 'dd',
			args:  'if=/dev/zero of=' + file + 
				' bs=' + req.params.filesize + ' count=1' + 
				' && mkfs.ext3 ' + file + 
				' && mount -o loop ' + file + 
				' /mnt/vm' + req.params.container + '/rootfs'
		]
	, (output) ->
		res.send output

module.exports.setnetworklimit = (req, res, next) ->
	res.send 'container_setnetworklimit NOT IMPLEMENTED'
	#
	# to limit network bandwidth per container, you'll want to use the tc utility.
	# Keep in mind you'll need to use separate bridges (br0, br1) for each container if you go this route.
	# Don't forget to edit the config of each VM to match your new bridge if you do so.