module.exports = -> 

restify 	= require("restify")
log 		= require("log4js").getLogger()
async 		= require("async")
mongoose	= require("mongoose")
AccessToken = mongoose.model('AccessToken')
User 		= mongoose.model('User')

module.exports.show = (req, res, next) ->
	# TODO validate auth_token

	getToken = (callback, results) ->
		AccessToken.findToken(req.params.token, callback)

	getUser = (callback, results) ->
		User.findUserById(results.token.user, callback)

	validate = (callback, results) ->
		unless results.user
			log.warn "invalid token=#{req.params.token}"
			return callback(new Error("Invalid token: unable to find associated user"))

		callback()

	async.auto
		token: [getToken]
		user: ['token', getUser]
		validate: ['user', validate]
	, (err, results) ->
		if err
			return next(new restify.InternalError(err))

		unless results.token
			return next(new restify.ResourceNotFoundError("Token not found."))

		data = 
			user:
				id: results.user._id	
				account_id: results.user.def_account

			auth_secret: results.token.auth_secret

		res.json data
