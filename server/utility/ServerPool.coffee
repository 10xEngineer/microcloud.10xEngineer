module.exports = ->

log = require("log4js").getLogger()
#server = require("../server")
commands = require("../commands/commands")
dataStructures = require("./DataStructures")
maxHosts = 3
maxContainersPerHost = 5
destination = "local"

###

Session =
	id: String
	owner_id: String
	status: String
	numContainers: 0
	containers: []
	storageURL: String
###

class Pool 
	constructor: (_destination, _maxHosts, _maxContainersPerHost) ->
		@maxHosts = _maxHosts
		@maxContainersPerHost = _maxContainersPerHost
		@destination = _destination
		@allocatedContainers = 0
		@maxAllowedContainers = maxHosts * maxContainersPerHost
		@sessions = []
		@owners = []
		@hosts = []
		@containers = []

	_allocate : (i , numContainers, owner_id, session_id) ->
		log.debug "before: hosts[" + i + "] = " + @hosts[i].containers.length
		n = 0
		containers = []
		while n < numContainers
			@allocatedContainers = @allocatedContainers + 1
			
			@hosts[i].containers.push
				id: @allocatedContainers
				status: "Allocated"
				host_id: @hosts[i].id
				owner_id: owner_id
				session_id: session_id
				prevHost_id: null

			n++

		log.debug numContainers + " allocated on Host [" + @hosts[i].id + "] for owner: " + owner_id + ", session: " + session_id
		log.debug "after:  hosts[" + i + "] = " + @hosts[i].containers.length
		return @hosts[i].containers

	allocate : (numContainers, owner_id, session_id) ->
		if (@allocatedContainers + numContainers) > @maxAllowedContainers
			log.debug "Maximum Containers and/or Hosts exceeded. No allocation allowed."  
			return []

		while true
			i = 0

			while i < @hosts.length 
				if (@maxContainersPerHost - @hosts[i].containers.length) >= numContainers
					return @_allocate i, numContainers, owner_id, session_id
				i++

			if @hosts.length < @maxHosts
				@hosts.push
					id: @hosts.length + 1
					containers: []
				#child = commands.cli.execute_command("localhost", "./scripts/startserver.sh", [ destination ], (output) ->
				#	log.debug output
				return @_allocate @hosts.length-1 , numContainers, owner_id, session_id

			else
				log.debug "reach max hosts, still cannot allocated " + numContainers
				return []

	restore : (containersIds, owner_id, session_id) ->
		"NOT IMPLEMENTED YET"

	deallocateByOwner : (owner_id, action) ->
		"NOT IMPLEMENTED YET"

	deallocateBySession : (session_id, action) ->
		"NOT IMPLEMENTED YET"

	hibernate : (containerIds, storageURL) ->
		"NOT IMPLEMENTED YET"

	shutdown : (containerIds) ->
		"NOT IMPLEMENTED YET"

module.exports = Pool