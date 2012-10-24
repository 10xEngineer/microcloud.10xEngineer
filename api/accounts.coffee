module.exports = -> 

restify 	= require("restify")
log 		= require("log4js").getLogger()
async 		= require("async")
mongoose	= require("mongoose")
Account 	= mongoose.model('Account')

module.exports.show = (req, res, next) ->
	Account
		.findOne({handle: req.params.account})
		.exec (err, account) ->
			if err
				return next(new restify.InternalError(err))

			unless account
				return next(new restify.ResourceNotFoundError("Account not found"))

			res.json account

