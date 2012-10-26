log 		= require("log4js").getLogger()
mongoose 	= require 'mongoose'
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId

timestamps = require "../utility/timestamp_plugin"

TemplateUpdates = new Schema
	version: String
	description: String

	created_at: Date


Template = new Schema
	name: String
	version: String

	description: String
	maintainer: String
	homepage: String

	managed: {type: Boolean, default: false}

	updates: [TemplateUpdates]

	# TODO how to do versioning

Template.plugin(timestamps)

module.exports.register = mongoose.model 'Template', Template