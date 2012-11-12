log 			= require("log4js").getLogger()
restify 		= require 'restify'
mongoose 		= require 'mongoose'
async 			= require 'async'
AccessToken		= mongoose.model('AccessToken')
account			= mongoose.model('Account')

User 			= mongoose.model('User')

module.exports.get_token = (token, next) ->
	getToken = (callback, results) ->
		AccessToken.findToken token, (err, token) ->
			if err
				return callback(err)

			callback(null, token)

	getUser = (callback, results) ->
		unless results.token
			return callback(null)

		User.findUserById(results.token.user_id, callback)

	async.auto
		token: getToken
		user: ['token', getUser]
	, (err, results) ->
		if err
			return next(err)

		unless results.token
			return next(null, null)

		# FIXME fill-in limits not defined within default profile

		data = 
			user:
				id: results.user._id	
				account_id: results.user.def_account
				limits: results.user.limits

			auth_secret: results.token.auth_secret

		return next(null, data)

module.exports.get_account = (account_handle, callback) ->
	Account
		.findOne({handle: account_handle})
		.exec (err, account) ->
			if err
				return callback(err)

			return callback(null, account)

