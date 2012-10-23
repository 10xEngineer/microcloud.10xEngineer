module.exports = ->

log 		= require("log4js").getLogger()
restify		= require("restify")
mongoose 	= require("mongoose")
async 		= require "async"
Pool		= mongoose.model 'Pool'

module.exports.index = (req, res, next) ->
	# FIXME extended properties for operators

	Pool
		.find({disabled: false})
		.select(name:1, _id:0)
		.exec (err, pools) ->
			if err
				return next(new restify.InternalError("Unable to retrieve pools: #{err}"))

			res.json pools

module.exports.show = (req, res, next) ->
	Pool.find_by_name req.params.pool, (err, pool) ->
		if err
			return next(new restify.InternalError("Unable to retrieve pools: #{err}"))

		res.json pool