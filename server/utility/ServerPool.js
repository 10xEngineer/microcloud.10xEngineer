(function() {
  var Host, Pool, commands, dataStructures, destination, maxContainersPerHost, maxHosts;

  module.exports = function() {};

  commands = require("../commands/commands");

  dataStructures = require("./DataStructures");

  maxHosts = 3;

  maxContainersPerHost = 5;

  destination = "local";

  Host = (function() {

    function Host(id, containers) {
      this.id = id;
      this.containers = containers;
    }

    return Host;

  })();

  /*
  Container =
  	id: String
  	status: String
  	host_id: String
  	owner_id: String
  	session_id: String
  	prevHost_id: String
  
  class Session =
  	constructor: (_destination, _maxHosts, _maxContainersPerHost) ->
  	id: String
  	owner_id: String
  	status: String
  	numContainers: 0
  	containers: []
  	storageURL: String
  */

  Pool = (function() {

    function Pool(_destination, _maxHosts, _maxContainersPerHost) {
      this.maxHosts = _maxHosts;
      this.maxContainersPerHost = _maxContainersPerHost;
      this.destination = _destination;
      this.allocatedContainers = 0;
      this.maxAllowedContainers = maxHosts * maxContainersPerHost;
      this.sessions = [];
      this.owners = [];
      this.hosts = [];
      this.containers = [];
    }

    Pool.prototype.allocate = function(numContainers, owner_id, session_id) {
      var i, n;
      if ((this.allocatedContainers + numContainers) > this.maxAllowedContainers) {
        return "Maximum Containers and/or Hosts exceeded. No allocation allowed.";
      }
      i = 0;
      this.hosts.push(new Host(this.hosts.length + 1, []));
      this.hosts.push(new Host(this.hosts.length + 1, []));
      this.hosts.push(new Host(this.hosts.length + 1, []));
      while (i++ < this.hosts.length && (this.maxContainersPerHost - this.hosts[i].containers.length) >= numContainers) {
        console.log("hosts[" + i + "] = " + this.hosts[i].containers.length);
        n = 0;
        while (n < numContainers) {
          this.allocatedContainers = this.allocatedContainers + 1;
          this.hosts[i].containers.push(new Container({
            id: this.allocatedContainers,
            status: "Allocated",
            host_id: this.hosts[i].id,
            owner_id: owner_id,
            session_id: session_id,
            prevHost_id: null
          }));
          n++;
        }
        console.log(numContainers + " allocated on Host [" + this.hosts[i].id + "] for owner: " + owner_id + ", session: " + session_id);
        return;
      }
      this.hosts.push(new Host(this.hosts.length + 1, []));
    };

    Pool.prototype.restore = function(containersIds, owner_id, session_id) {
      return "NOT IMPLEMENTED YET";
    };

    Pool.prototype.deallocateByOwner = function(owner_id, action) {
      return "NOT IMPLEMENTED YET";
    };

    Pool.prototype.deallocateBySession = function(session_id, action) {
      return "NOT IMPLEMENTED YET";
    };

    Pool.prototype.hibernate = function(containerIds, storageURL) {
      return "NOT IMPLEMENTED YET";
    };

    Pool.prototype.shutdown = function(containerIds) {
      return "NOT IMPLEMENTED YET";
    };

    return Pool;

  })();

  module.exports = Pool;

}).call(this);
