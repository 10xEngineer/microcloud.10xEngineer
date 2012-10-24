log 		= require("log4js").getLogger()
mongoose 	= require "mongoose"
Schema		= mongoose.Schema
ObjectId 	= Schema.ObjectId;

timestamps 	= require "../utility/timestamp_plugin"

Machine = new Schema
	uuid: String

	account: ObjectId
	node: ObjectId
	lab: ObjectId

	state: String
	template: String

Machine.plugin(timestamps)

module.exports.register = mongoose.model 'Machine', Machine