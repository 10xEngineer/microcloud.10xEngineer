module.exports = ->

log 		= require("log4js").getLogger()
restify 	= require "restify"
mongoose 	= require "mongoose"
broker 		= require "../server/broker"
param_helper= require "../server/utils/param_helper"
async 		= require "async"
Key 		= mongoose.model 'Key'

#
# Key management
#
module.exports.index = (req, res, next) ->
	Key
		.find(user_id: req.params.user)
		.where("deleted_at").equals(null)
		.select({_id: 0})
		.exec (err, keys) ->
			if err
				return callback(new restify.InternalError("Unable to retrieve keys: #{err}"))

			res.send keys

module.exports.show = (req, res, next) ->
	Key
		.findOne({name: req.params.key, user_id: req.params.user})
		.where("deleted_at").equals(null)
		.exec (err, key) ->
			if err
				return next(new restify.InternalError("Unable to retrieve key: #{err}")) 

			unless key
				return next(new restify.NotFoundError("Key not found"))

			res.send key

module.exports.create = (req, res, next) ->
	try
		data = JSON.parse req.body
	catch e
		return next(new restify.BadRequestError("Invalid data"))

	checkParams = (callback, results) -> 
		param_helper.checkPresenceOf data, ['name','key'], callback

	validateKey = (callback, results) ->
		key_data = 
			key: data.key

		task = broker.dispatch 'key', 'validate', key_data
		task.on 'data', (message) ->
			return callback(null, message.options.fingerprint)

		task.on 'error', (message) ->
			return callback(new restify.BadRequestError(message.options.reason))

	uniqueKey = (callback, results) ->
		key = Key.find_by_fingerprint results.fingerprint, req.params.user, (err, other_key) ->
			if err
				return callback(new restify.InternalError("Unable to verify key: #{err}"))

			if other_key
				return callback(new restify.ConflictError("Key with fingerprint #{results.fingerprint} already exists"))

			return callback(null)

	saveKey = (callback, results) ->
		key_data = 
			name: data.name
			fingerprint: results.fingerprint
			public_key: data.key

			user_id: req.params.user

		key = new Key(key_data)
		key.save (err) ->
			if err
				return callback(new restify.InternalError("Unable to save key"))

			callback(null, key)

	async.auto
		params: checkParams
		fingerprint: ['params', validateKey]
		unique: ['fingerprint', uniqueKey]
		key: ['unique', saveKey]
	, (err, results) ->
		if err
			return next(err)

		res.send 201, results.key

module.exports.destroy = (req, res, next) ->
	getKey = (callback, results) ->
		Key
			.findOne({name: req.params.key, user_id: req.params.user})
			.where("deleted_at").equals(null)
			.exec (err, key) ->
				if err
					return callback(new restify.InternalError("Unable to verify key: #{err}"))

				unless key
					return callback(new restify.NotFoundError("Key not found"))

				return callback(null, key)

	removeKey = (callback, results) ->
		console.log results
		results.key.deleted_at = Date.now()
		results.key.save (err) ->
			if err
				return next(new restify.InternalError("Unable to remove key: #{err}"))

			callback(null)

	async.auto
		key: getKey
		remove: ['key', removeKey]
	, (err, results) ->
		if err
			return next(err)

		res.send 200
