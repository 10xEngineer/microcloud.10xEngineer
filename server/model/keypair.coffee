log = require("log4js").getLogger()

mongoose  = require 'mongoose'
Schema    = mongoose.Schema

timestamps    = require "../utility/timestamp_plugin"

KeypairSchema = new Schema
	fingerprint: {type:String, unique: true}
	ssh_public_key: String

KeypairSchema.plugin timestamps

module.exports.schema = KeypairSchema
module.exports.register = mongoose.model 'Keypair', KeypairSchema
