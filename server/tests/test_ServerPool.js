(function() {
  var Pool, pool;

  Pool = require("../utility/ServerPool.js");

  pool = new Pool("local", 2, 4);

  pool.allocate(2, "anderson", "session1");

  pool.allocate(2, "anderson", "session1");

  pool.allocate(2, "anderson", "session1");

  pool.allocate(2, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

  pool.allocate(2, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

  pool.allocate(3, "anderson", "session1");

}).call(this);
