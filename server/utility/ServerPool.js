(function() {
  var HashTable, Pool, commands, dataStructures, destination, log, maxContainersPerHost, maxHosts;

  module.exports = function() {};

  log = require("log4js").getLogger();

  commands = require("../commands/commands");

  dataStructures = require("./DataStructures");

  HashTable = require("./HashTable");

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
      this.hostIdSequence = 0;
      this.containerIdSequence = 0;
    }

    Pool.prototype._allocate = function(i, numContainers, owner_id, session_id) {
      var container, container_id, containers, n, _i, _len;
      log.debug("before: hosts[" + i + "] = " + this.hosts[i].containers.length);
      n = 0;
      containers = [];
      while (n < numContainers) {
        this.allocatedContainers = this.allocatedContainers + 1;
        container_id = this.containerIdSequence++;
        containers.push({
          container_id: container_id,
          status: "Allocated",
          host_id: i,
          owner_id: owner_id,
          session_id: session_id,
          prevHost_id: null
        });
        n++;
      }
      for (_i = 0, _len = containers.length; _i < _len; _i++) {
        container = containers[_i];
        this.hosts[i].containers.setItem(container.container_id, container);
      }
      log.debug(numContainers + " allocated on Host [" + this.hosts[i].id + "] for owner: " + owner_id + ", session: " + session_id);
      log.debug("after:  hosts[" + i + "] = " + this.hosts[i].containers.length);
      log.debug(this.hosts);
      return containers;
    };

    Pool.prototype.allocate = function(numContainers, owner_id, session_id) {
      var host_id, i;
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
          host_id = this.hostIdSequence++;
          this.hosts[host_id] = {
            id: host_id,
            containers: new HashTable()
          };
          return this._allocate(host_id, numContainers, owner_id, session_id);
        } else {
          log.debug("reach max hosts, still cannot allocated " + numContainers);
          return [];
        }
      }
    };

    Pool.prototype.deallocate = function(containers) {
      var container, _i, _j, _len, _len2, _ref;
      if (containers instanceof HashTable) {
        log.debug('is HashTable');
        _ref = containers.values();
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          container = _ref[_i];
          log.debug("delete container " + container.container_id + " from host " + container.host_id);
          delete this.hosts[container.host_id].containers.removeItem(container.container_id);
          this.allocatedContainers--;
        }
      } else if (containers instanceof Array) {
        log.debug('is array');
        for (_j = 0, _len2 = containers.length; _j < _len2; _j++) {
          container = containers[_j];
          log.debug("delete container " + container.container_id + " from host " + container.host_id);
          delete this.hosts[container.host_id].containers.removeItem(container.container_id);
          this.allocatedContainers--;
        }
      } else {
        log.debug("delete container " + containers.container_id + " from host " + containers.host_id);
        delete this.hosts[containers.host_id].containers.removeItem(containers.container_id);
        this.allocatedContainers--;
      }
      log.debug(this.hosts);
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
