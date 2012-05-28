/*
	Manage a pool of virtual machines, which are the hosts to a sub-pool of virtual containers
	Each VM has a specific capacity of containers, and new VM's are allocated/returned as the containers are added/removed

	Hosts: Vagrant or EC2 servers running Ubuntu
	Containers: LXC containers running on a host

	NOTES:
	Ideally we want to keep all containers for a session on a single machine so that we can restore/hibernate quickly to make it UX friendly for the user
	However, we need a decent strategy to handle fragmentation, so that we always have the minimum number of Hosts running at any time.

*/

module.exports = function() {}
var server = require('./server');
var commands = require('./commands/commands');
var dataStructures = require('./DataStructures');

var maxHosts = 3;
var maxContainersPerHost = 5; //TODO: Make this dynamic depending on the host / container capability/requirements
var destination = "local"; // or ec2

var Host = function() {
	  id : String // e.g. the EC2 instance id
	, containers = dataStructures.stack() // stack of containers
}

var Container = function() {
	  id : String
	, status : String // empty, [Allocated, Running, Hibernating]
	, host_id : String // The id of the host 
	, owner_id : String // The id of the owner/user of this instance
	, session_id : String // The id of the session (a user may have many sessions)
	, prevHost_id : String // if the container has been hibernating, then the prevHost will have a cache of the container, so try that first
}

// A session is equivalent to a lesson where the user has undertaken a task, we want to preserve the state of their work, 
// which might have needed N containers, eg. as in "install LAMP servers on a 3 tier setup"
var Session = function() {
	  id : String
	, owner_id : String // The id of the owner
	, status : String // InUse, Hibernating, Terminated
	, numContainers : int // The number of containers
	, containers = [] // The containers list
	, storageURL : String // Where the containers will get stored
}

// destination = local | ec2
var Pool = module.exports = function(_destination, _maxHosts, _maxContainersPerHost) {
	maxHosts = _maxHosts;
	maxContainersPerHost = _maxContainersPerHost;
	destination = _destination; // local or ec2
	
	var allocatedContainers = 0;
	var maxContainers = maxHosts * maxContainersPerHost;
	var sessions = [];
	var owners = [];
	
	var hosts = dataStructures.stack();
	var containers = [];

	// Allocate new containers from an available host or start a new host if needed
	var allocate = function(numContainers, owner_id, session_id) {
		// Check for max hosts and containers reached first
		if( (allocatedContainers + numContainers) > maxAllowedContainers ) {
			return "Maximum Containers and/or Hosts exceeded. No allocation allowed."
		}
		
		// Iterate through the sorted hosts list (descending by allocated Containers), looking for the first host with the required number of containers available
		// else startup another host - if below max host limit
		var h=0;
		// Is there free space?
		while( h < hosts.length && (maxContainersPerHost - hosts[i].containers.length) >= numContainers ) {
			log.debug("hosts["+n"] = "+hosts[i].containers.length);
			// allocate new containers
			for(n=0;n<numContainers;n++) {
				allocatedContainers = allocatedContainers + 1;
				hosts[i].containers.push( new Container({
						id : allocatedContainers,
						status : "Allocated",
						host_id : hosts[i].id,
						owner_id : owner_id,
						session_id : session_id,
						prevHost_id : null
					});
				);
			}
			// All allocated so break out of the loop successfully
			return numContainers + " allocated on Host [" + hosts[i].id + "] for owner: " + owner_id + ", session: " + session_id;
		}
		
		// No hosts with the min required container space
		// Add a new host
		//TODO: This really needs to be async and fixed!!!!
		// it should call something like commands.server.start(:destination)
		var child = commands.cli.execute_command( 'localhost', './scripts/startserver.sh', [destination], function(output) {
			log.debug(output);
			//TODO : do something with this data
		} );
		hosts.push(new Host({
				id: hosts.length + 1,
				containers = []; // starts off empty
			});
		);
	}

	// Restore the LXC images from storage
	var restore = function([containersIds], owner_id, session_id) {
		return "NOT IMPLEMENTED YET";
	}

	// action here is: Return to pool, save to storage
	var deallocateByOwner = module.exports = function(owner_id, action) {
		return "NOT IMPLEMENTED YET";
	}

	// action here is: Return to pool, save to storage
	var deallocateBySession = module.exports = function(session_id, action) {
		return "NOT IMPLEMENTED YET";
	}

	var hibernate = function([containerIds], storageURL) {
		return "NOT IMPLEMENTED YET";
	}
	
	var shutdown = function([containerIds]) {
		return "NOT IMPLEMENTED YET";
	}
}