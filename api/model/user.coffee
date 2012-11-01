log 		= require("log4js").getLogger()
mongoose 	= require "mongoose"
timestamps 	= require "../../server/utility/timestamp_plugin"
ObjectId 	= mongoose.Schema.ObjectId

User = new mongoose.Schema
	email: String
	name: String
	
	cpwd: String
	salt: String

	def_account: ObjectId

	service: {type: Boolean, default: false}
	disabled: {type: Boolean, default: false}
	tc_agreed: {type: Boolean, default: false}

User.plugin(timestamps)

User.statics.findUserById = (id, callback) ->
	mongoose.model('User')
		.findOne({_id: id})
		.exec (err, user) ->
			if err
				return callback(new Error("Unable to retrieve user: #{err}"))

			callback(null, user)

module.exports.register = mongoose.model 'User', User