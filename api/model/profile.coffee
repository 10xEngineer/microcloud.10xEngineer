log 		= require("log4js").getLogger()
mongoose 	= require 'mongoose'
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId

timestamps = require "../../server/utility/timestamp_plugin"

# TODO lab environments 
# TODO networks

Profile = new Schema
	name: String

	machines: Number
	memory: Number

	transfer: Number

Profile.plugin(timestamps)

