log 		= require("log4js").getLogger()
mongoose 	= require "mongoose"
timestamps 	= require "../../server/utility/timestamp_plugin"
ObjectId 	= mongoose.Schema.ObjectId

AccessToken = new mongoose.Schema {
	user: ObjectId
	alias: String
	auth_token: String
	auth_secret: String
}, {
	collection: 'access_tokens'
}

AccessToken.plugin(timestamps)

module.exports.register = mongoose.model 'AccessToken', AccessToken