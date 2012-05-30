Pool = require("../utility/ServerPool.js")
pool = new Pool("local", 5, 4)
pool.allocate(3, "anderson", "session1")
