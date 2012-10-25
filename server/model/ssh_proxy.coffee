log 		= require("log4js").getLogger()
mongoose 	= require 'mongoose'
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId

timestamps = require "../utility/timestamp_plugin"

SSHProxy = new Schema {
	lab_proxy: String
	key: ObjectId

	machine: ObjectId
}, {
	collection: 'ssh_proxies'
}

SSHProxy.plugin(timestamps)

module.exports.register = mongoose.model 'SSHProxy', SSHProxy