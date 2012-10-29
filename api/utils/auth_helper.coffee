log 			= require("log4js").getLogger()
restify 		= require 'restify'
mongoose 		= require 'mongoose'
async 			= require 'async'
AccessToken 	= mongoose.model('AccessToken')
Account 		= mongoose.model('Account')
User 			= mongoose.model('User')

module.exports.get_token = (token, callback) ->
	getToken = (callback, results) ->
		AccessToken.findToken(token, callback)

	getUser = (callback, results) ->
		User.findUserById(results.token.user, callback)

	validate = (callback, results) ->
		unless results.user
			log.warn "invalid token=#{token}"
			return callback(new Error("Invalid token: unable to find associated user"))

		callback()

	async.auto
		token: [getToken]
		user: ['token', getUser]
		validate: ['user', validate]
	, (err, results) ->
		if err
			return callback(err)

		unless results.token
			return callback(null, null)

		data = 
			user:
				id: results.user._id	
				account_id: results.user.def_account

			auth_secret: results.token.auth_secret

		return callback(null, data)

module.exports.get_account = (account_handle, callback) ->
	Account
		.findOne({handle: account_handle})
		.exec (err, account) ->
			if err
				return callback(err)

			return callback(null, account)

