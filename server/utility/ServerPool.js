(function() {
  var Container, Host, Pool, Session, commands, dataStructures, destination, maxContainersPerHost, maxHosts, server;

  module.exports = function() {};

  server = require("../server");

  commands = require("../commands/commands");

  dataStructures = require("./DataStructures");

  maxHosts = 3;

  maxContainersPerHost = 5;

  destination = "local";

  Host = {
    id: String,
    containers: dataStructures.stack()
  };

  Container = {
    id: String,
    status: String,
    host_id: String,
    owner_id: String,
    session_id: String,
    prevHost_id: String
  };

  Session = {
    id: String,
    owner_id: String,
    status: String,
    numContainers: int,
    containers: [],
    storageURL: String
  };

  Pool = module.exports = function(_destination, _maxHosts, _maxContainersPerHost) {
    var allocate, allocatedContainers, containers, deallocateByOwner, deallocateBySession, hibernate, hosts, maxAllowedContainers, owners, restore, sessions, shutdown;
    maxHosts = _maxHosts;
    maxContainersPerHost = _maxContainersPerHost;
    destination = _destination;
    allocatedContainers = 0;
    maxAllowedContainers = maxHosts * maxContainersPerHost;
    sessions = [];
    owners = [];
    hosts = dataStructures.stack();
    containers = [];
    allocate = function(numContainers, owner_id, session_id) {
      var child, i, n;
      if ((allocatedContainers + numContainers) > maxAllowedContainers) {
        return "Maximum Containers and/or Hosts exceeded. No allocation allowed.";
      }
      i = 0;
      while (i++ < hosts.length && (maxContainersPerHost - hosts[i].containers.length) >= numContainers) {
        log.debug("hosts[" + i + "] = " + hosts[i].containers.length);
        n = 0;
        while (n < numContainers) {
          allocatedContainers = allocatedContainers + 1;
          hosts[i].containers.push(new Container({
            id: allocatedContainers,
            status: "Allocated",
            host_id: hosts[i].id,
            owner_id: owner_id,
            session_id: session_id,
            prevHost_id: null
          }));
          n++;
        }
        return numContainers + " allocated on Host [" + hosts[i].id + "] for owner: " + owner_id + ", session: " + session_id;
      }
      child = commands.cli.execute_command("localhost", "./scripts/startserver.sh", [destination], function(output) {
        return log.debug(output);
      });
      return hosts.push(new Host({
        id: hosts.length + 1,
        containers: []
      }));
    };
    restore = function(containersIds, owner_id, session_id) {
      return "NOT IMPLEMENTED YET";
    };
    deallocateByOwner = module.exports = function(owner_id, action) {
      return "NOT IMPLEMENTED YET";
    };
    deallocateBySession = module.exports = function(session_id, action) {
      return "NOT IMPLEMENTED YET";
    };
    hibernate = function(containerIds, storageURL) {
      return "NOT IMPLEMENTED YET";
    };
    return shutdown = function(containerIds) {
      return "NOT IMPLEMENTED YET";
    };
  };

}).call(this);
