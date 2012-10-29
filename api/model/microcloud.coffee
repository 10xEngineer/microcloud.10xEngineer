log 		= require("log4js").getLogger()
mongoose 	= require "mongoose"
timestamps 	= require "../../server/utility/timestamp_plugin"
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId

timestamps = require "../../server/utility/timestamp_plugin"

Microcloud = new Schema
	name: String
	endpoint_url: String

	disabled: {type: Boolean, default: false}

Microcloud.plugin(timestamps)

module.exports.register = mongoose.model 'Microcloud', Microcloud