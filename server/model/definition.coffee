mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"

ObjectId = mongoose.Schema.ObjectId

# TODO validate version
# TODO get most recent

VMSchema = new mongoose.Schema
	name: String
	vm_type: String
	hostname: String
	run_list: []

DefinitionSchema = new mongoose.Schema({
	# belongs to Lab
	lab: {type: ObjectId, ref: 'Lab'}

	# basic metadata
	revision: { type: String, required: true }
	version: { type: String, required: true }
	handler: {type: String, required: true }
	
	# other metadata
	maintainer: String
	maintainer_email: String
	description: String

	vms: [VMSchema]
})

DefinitionSchema.index({ lab:1, version: 1 }, { unique: true })
DefinitionSchema.plugin(timestamps)

module.exports.register = mongoose.model 'Definition', DefinitionSchema
