log 			= require("log4js").getLogger()
mongoose 		= require 'mongoose'
Schema 			= mongoose.Schema
ObjectId 		= Schema.ObjectId

timestamps = require "../utility/timestamp_plugin"

Snapshot = new Schema
	machine_id: ObjectId
	machine_name: String

	name: String
	state: String

	uuid: String
	hostname: String

	used_size: Number
	real_size: Number

	timestamp: Number

	account: ObjectId

Snapshot.plugin(timestamps)

Snapshot.methods.delete = (callback) ->
	this.deleted_at = Date.now()
	this.save (err) ->
		return callback(err)

module.exports.register = mongoose.model 'Snapshot', Snapshot