# lab.cofee
#
# Lab is a fundamental concepts of 10xLabs. It provides current 
# representation (configuration/operational) of a project. Each 
# lab has one or more versioned definitions, internal representation
# of 'infrastructure as code'.
#
mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"

ObjectId = mongoose.Schema.ObjectId

LabSchema = new mongoose.Schema({
	# TODO link to owner (user/domain)
	name: { type: String, required: true }
	token: { type: String, unique: true }
	repo: String

	current_definition: {type: ObjectId, ref: 'Definition'}
})

LabSchema.plugin(timestamps)

module.exports.register = mongoose.model 'Lab', LabSchema
