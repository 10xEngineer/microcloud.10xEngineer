log 			= require("log4js").getLogger()
mongoose 		= require 'mongoose'
Schema 			= mongoose.Schema
ObjectId 		= Schema.ObjectId

timestamps = require "../utility/timestamp_plugin"

Snapshot = new Schema
	machine_id: ObjectId

	name: String

	used_size: Number
	real_size: Number

	account: ObjectId

Snapshot.plugin(timestamps)

module.exports.register = mongoose.model 'Snapshot', Snapshot