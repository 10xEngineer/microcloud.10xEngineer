module.exports = -> 

restify 	= require("restify")
log 		= require("log4js").getLogger()
mongoose	= require("mongoose")
AccessToken = mongoose.model('AccessToken')

module.exports.show = (req, res, next) ->
	# TODO validate auth_token
	AccessToken
		.findOne({auth_token: req.params.token})
		.populate('user')
		.exec (err, token) ->
			if err
				return next(new restify.InternalError("Unable to retrieve token"))

			unless token
				return next(new restify.ResourceNotFoundError("Invalid token"))

			data = 
				user: token.user.name
				auth_secret: token.auth_secret

			res.send JSON.stringify(data)
