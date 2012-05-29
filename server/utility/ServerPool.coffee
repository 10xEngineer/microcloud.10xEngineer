module.exports = ->

server = require("../server")
commands = require("../commands/commands")
dataStructures = require("./DataStructures")
maxHosts = 3
maxContainersPerHost = 5
destination = "local"
Host =
	id: String
	containers: dataStructures.stack()

Container =
	id: String
	status: String
	host_id: String
	owner_id: String
	session_id: String
	prevHost_id: String

Session =
	id: String
	owner_id: String
	status: String
	numContainers: int
	containers: []
	storageURL: String

Pool = module.exports = (_destination, _maxHosts, _maxContainersPerHost) ->
	maxHosts = _maxHosts
	maxContainersPerHost = _maxContainersPerHost
	destination = _destination
	allocatedContainers = 0
	maxAllowedContainers = maxHosts * maxContainersPerHost
	sessions = []
	owners = []
	hosts = dataStructures.stack()
	containers = []
	allocate = (numContainers, owner_id, session_id) ->
		return "Maximum Containers and/or Hosts exceeded. No allocation allowed."  if (allocatedContainers + numContainers) > maxAllowedContainers
		i = 0
		while i++ < hosts.length and (maxContainersPerHost - hosts[i].containers.length) >= numContainers
			log.debug "hosts[" + i + "] = " + hosts[i].containers.length
			n = 0
			while n < numContainers
				allocatedContainers = allocatedContainers + 1
				hosts[i].containers.push new Container(
					id: allocatedContainers
					status: "Allocated"
					host_id: hosts[i].id
					owner_id: owner_id
					session_id: session_id
					prevHost_id: null
				)
				n++
			return numContainers + " allocated on Host [" + hosts[i].id + "] for owner: " + owner_id + ", session: " + session_id
		child = commands.cli.execute_command("localhost", "./scripts/startserver.sh", [ destination ], (output) ->
			log.debug output
		)
		hosts.push new Host(
			id: hosts.length + 1
			containers: []
		)

	restore = (containersIds, owner_id, session_id) ->
		"NOT IMPLEMENTED YET"

	deallocateByOwner = module.exports = (owner_id, action) ->
		"NOT IMPLEMENTED YET"

	deallocateBySession = module.exports = (session_id, action) ->
		"NOT IMPLEMENTED YET"

	hibernate = (containerIds, storageURL) ->
		"NOT IMPLEMENTED YET"

	shutdown = (containerIds) ->
		"NOT IMPLEMENTED YET"
