pool = require("../utility/ServerPool.js")("local", 5, 4)
console.log pool.allocate(3, "anderson", "session1")
