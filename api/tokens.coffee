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
		User.findUserById(results.getToken.user, callback)

	validate = (callback, results) ->
		unless results.getUser
			return callback(new Error("Invalid token: unable to find associated user"))

		callback()

	async.auto
		getToken: [getToken]
		getUser: ['getToken', getUser]
		validate: ['getUser', validate]
	, (err, results) ->
		if err
			return next(new restify.InternalError(err))

		unless results.getToken
			return next(new restify.ResourceNotFoundError("Token not found."))

		data = 
			user:
				def_account: results.getUser.def_account
			auth_secret: results.getToken.auth_secret

		res.send JSON.stringify(data)
