log 		= require("log4js").getLogger()
mongoose 	= require 'mongoose'
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId

timestamps = require "../utility/timestamp_plugin"

Node = new Schema
	hostname: String
	provider: String
	rsa_key: String

	pool: ObjectId
	disabled: {type: Boolean, default: false}

Node.plugin timestamps

Node.statics.find_by_hostname = (hostname, callback) ->
	mongoose.model('Node')
		.findOne({hostname: hostname})
		.where('deleted_at').equals(null)
		.exec(callback)

module.exports.register = mongoose.model 'Node', Node