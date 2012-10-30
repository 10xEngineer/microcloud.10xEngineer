module.exports = -> 

restify 	= require("restify")
log 		= require("log4js").getLogger()
async 		= require("async")
mongoose	= require("mongoose")
auth_helper = require "./utils/auth_helper"
User 		= mongoose.model('User')

module.exports.show = (req, res, next) ->
	auth_helper.get_token req.params.token, (err, token_data) ->
		if err
			return next(new restify.InternalError(err))

		unless token_data
			return next(new restify.NotFoundError("Invalid token."))

		res.json token_data
