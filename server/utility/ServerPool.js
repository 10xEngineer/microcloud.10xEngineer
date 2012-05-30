(function() {
  var Pool, commands, dataStructures, destination, log, maxContainersPerHost, maxHosts;

  module.exports = function() {};

  log = require("log4js").getLogger();

  commands = require("../commands/commands");

  dataStructures = require("./DataStructures");

  maxHosts = 3;

  maxContainersPerHost = 5;

  destination = "local";

  /*
  
  Session =
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

    Pool.prototype._allocate = function(i, numContainers, owner_id, session_id) {
      var containers, n;
      log.debug("before: hosts[" + i + "] = " + this.hosts[i].containers.length);
      n = 0;
      containers = [];
      while (n < numContainers) {
        this.allocatedContainers = this.allocatedContainers + 1;
        this.hosts[i].containers.push({
          id: this.allocatedContainers,
          status: "Allocated",
          host_id: this.hosts[i].id,
          owner_id: owner_id,
          session_id: session_id,
          prevHost_id: null
        });
        n++;
      }
      log.debug(numContainers + " allocated on Host [" + this.hosts[i].id + "] for owner: " + owner_id + ", session: " + session_id);
      log.debug("after:  hosts[" + i + "] = " + this.hosts[i].containers.length);
      return this.hosts[i].containers;
    };

    Pool.prototype.allocate = function(numContainers, owner_id, session_id) {
      var i;
      if ((this.allocatedContainers + numContainers) > this.maxAllowedContainers) {
        log.debug("Maximum Containers and/or Hosts exceeded. No allocation allowed.");
        return [];
      }
      while (true) {
        i = 0;
        while (i < this.hosts.length) {
          if ((this.maxContainersPerHost - this.hosts[i].containers.length) >= numContainers) {
            return this._allocate(i, numContainers, owner_id, session_id);
          }
          i++;
        }
        if (this.hosts.length < this.maxHosts) {
          this.hosts.push({
            id: this.hosts.length + 1,
            containers: []
          });
          return this._allocate(this.hosts.length - 1, numContainers, owner_id, session_id);
        } else {
          log.debug("reach max hosts, still cannot allocated " + numContainers);
          return [];
        }
      }
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
