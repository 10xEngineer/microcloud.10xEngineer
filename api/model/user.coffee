log 		= require("log4js").getLogger()
mongoose 	= require "mongoose"
timestamps 	= require "../../server/utility/timestamp_plugin"
ObjectId 	= mongoose.Schema.ObjectId

User = new mongoose.Schema
	email: String
	cpwd: String
	salt: String

	def_account: ObjectId

	service: {type: Boolean, default: false}
	disabled: {type: Boolean, default: false}

User.plugin(timestamps)

module.exports.register = mongoose.model 'User', User