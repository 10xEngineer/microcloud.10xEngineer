module.exports = ->

log = require("log4js").getLogger()
#server = require("../server")
commands = require("../commands/commands")
dataStructures = require("./DataStructures")
HashTable = require("./HashTable")
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
		@hostIdSequence = 0 
		@containerIdSequence = 0

	_allocate : (i , numContainers, owner_id, session_id) ->
		log.debug "before: hosts[" + i + "] = " + @hosts[i].containers.length
		n = 0
		containers = []
		while n < numContainers
			@allocatedContainers = @allocatedContainers + 1
			container_id = @containerIdSequence++
			containers.push
				container_id: container_id
				status: "Allocated"
				host_id: i
				owner_id: owner_id
				session_id: session_id
				prevHost_id: null

			n++

		for container in containers
			@hosts[i].containers.setItem container.container_id,container

		log.debug numContainers + " allocated on Host [" + @hosts[i].id + "] for owner: " + owner_id + ", session: " + session_id
		log.debug "after:  hosts[" + i + "] = " + @hosts[i].containers.length
		log.debug @hosts
		return containers

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
				host_id = @hostIdSequence++
				@hosts[host_id] = 
					id: host_id
					containers: new HashTable()
				
				#child = commands.cli.execute_command("localhost", "./scripts/startserver.sh", [ destination ], (output) ->
				#	log.debug output
				return @_allocate host_id , numContainers, owner_id, session_id

			else
				log.debug "reach max hosts, still cannot allocated " + numContainers
				return []

	deallocate : (containers) ->
		if containers instanceof HashTable 
			log.debug 'is HashTable'
			for container in containers.values()
				log.debug "delete container "+container.container_id+" from host "+container.host_id
				delete @hosts[container.host_id].containers.removeItem(container.container_id)
				@allocatedContainers--
		else if containers instanceof Array
			log.debug 'is array'
			for container in containers
				log.debug "delete container "+container.container_id+" from host "+container.host_id
				delete @hosts[container.host_id].containers.removeItem(container.container_id)
				@allocatedContainers--
		else
			log.debug "delete container "+containers.container_id+" from host "+containers.host_id
			delete @hosts[containers.host_id].containers.removeItem(containers.container_id)
			@allocatedContainers--
		log.debug @hosts
		return

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