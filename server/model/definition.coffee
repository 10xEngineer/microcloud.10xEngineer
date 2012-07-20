mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"

ObjectId = mongoose.Schema.ObjectId

# TODO validate version
# TODO get most recent

DefinitionSchema = new mongoose.Schema({
	# belongs to Lab
	lab: {type: ObjectId, ref: 'Lab'}

	# basic metadata
	version: { type: String, required: true }
	handler: {type: String, required: true }
	

	# other metadata
	maintainer: String
	maintainer_email: String
	description: String
})

DefinitionSchema.plugin(timestamps)

module.exports.register = mongoose.model 'Definition', DefinitionSchema
