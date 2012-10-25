log 		= require("log4js").getLogger()
mongoose 	= require 'mongoose'
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId

timestamps = require "../utility/timestamp_plugin"

Key = new Schema
	# TODO name should be unique (within user/account if shared)
	name: String

	fingerprint: String
	public_key: String

	account: ObjectId
	user: ObjectId

Key.plugin(timestamps)

Key.statics.find_by_fingerprint = (fingerprint, user_id, callback) ->
	# TODO include support for shared keys (ie. with account != null)
	mongoose.model('Key')
		.findOne({user: user_id, fingerprint: fingerprint})
		.where("meta.deleted_at").equals(null)
		.exec callback

module.exports.register = mongoose.model 'Key', Key