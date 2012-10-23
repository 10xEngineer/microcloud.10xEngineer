module.exports = ->

log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
async 		= require "async"
param_helper= require "../utils/param_helper"

#
# VM commands
#
module.exports.index = (req, res, next) ->
	# FIXME not yet migrated
	res.send 500, {}

module.exports.create = (req, res, next) ->
	try
		data = JSON.parse req.body
	catch e
		return next(new restify.BadDigestError("Invalid data"))


	checkParams = (callback, results) -> 
		param_helper.checkPresenceOf data, ['template','size','pool'], callback

	getPool = (callback, results) ->
		# TODO continue

	# TODO LRU for pool allocation

	async.auto
		checkParams: checkParams 
		pool: getPool
	, (err, results) ->
		if err
			return next(err)

		res.json 200, {}

module.exports.show = (req, res, next) ->
	# FIXME not yet migrated
	res.send 500, {}
