# lab.cofee
#
# Lab is a fundamental concepts of 10xLabs. It provides current 
# representation (configuration/operational) of a project. Each 
# lab has one or more versioned definitions, internal representation
# of 'infrastructure as code'.
#
log = require("log4js").getLogger()
mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"

ObjectId = mongoose.Schema.ObjectId

LabSchema = new mongoose.Schema({
	# TODO link to owner (user/domain) + add it to compound index (below)
	name: { type: String, required: true }
	token: { type: String, unique: true }
	repo: String

	current_definition: {type: ObjectId, ref: 'Definition'}
})

LabSchema.index({ name: 1 }, { unique: true })

LabSchema.plugin(timestamps)
LabSchema.plugin(state_machine, 'created')

LabSchema.statics.paths = ->
	"created":
		lock: (lab) ->
			log.debug "lab=#{lab.name} state=pending"
			"pending"

	"pending":
		confirm: (lab) ->
			log.debug "lab=#{lab.name} state=confirmed"

			"created"

module.exports.register = mongoose.model 'Lab', LabSchema
