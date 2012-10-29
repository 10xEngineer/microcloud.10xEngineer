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

AccessToken.statics.findToken = (token, callback) ->
	mongoose.model('AccessToken')
		.findOne({auth_token: token})
		.where("deleted_at").equals(null)
		.exec (err, token) ->
			if err
				return callback(new Error("Unable to retrieve token: #{err}"))

			callback(null, token)

module.exports.register = mongoose.model 'AccessToken', AccessToken