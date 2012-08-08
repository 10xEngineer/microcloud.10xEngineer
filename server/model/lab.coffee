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
Vm = mongoose.model 'Vm'

ObjectId = mongoose.Schema.ObjectId

AllocatedVMSchema = new mongoose.Schema({
	name: { type: String, required: true }
	vm: {type: ObjectId, ref: 'Vm'}
	# TODO attributes
	# TODO networking details
})

LabSchema = new mongoose.Schema({
	# TODO link to owner (user/domain) + add it to compound index (below)
	name: { type: String, required: true }
	token: { type: String, unique: true }
	repo: String

	current_definition: {type: ObjectId, ref: 'Definition'}

	operational: {
		vms: [AllocatedVMSchema]
		# TODO storage
		# TODO networks
	}
})

LabSchema.index({ name: 1 }, { unique: true })

LabSchema.plugin(timestamps)
LabSchema.plugin(state_machine, 'created')

#
# created -> running 
#
LabSchema.statics.paths = ->
	"created":
		vm_locked: (lab, vms) ->
			log.debug "lab=#{lab.name} received vm_locked"

	"pending":
		vm_allocated: (lab, active_vms) =>
			# TODO make re-usable (vm_running, vm_allocated)
			# FIXME this should be handled by lab workflow
			#vm_count = lab.definition.vms.length

			#if vm_count == active_vms.length
			# TODO doesn't really make sense
			return "pending"
			#else
			#	return "pending"

		confirm: (lab) ->
			log.debug "lab=#{lab.name} state=confirmed"
			"created"


#
# VM integration
#
LabSchema.addListener 'vmStateChange', (lab, vm, prev_state) ->
	action = "vm_#{vm.state}"

	vm_state = "available"
	switch vm.state
		when "allocated", "running" then vm_state = vm.state
	# TODO how to handle failing

	Vm
	.find({lab: lab._id})
	.where('state').equals(vm_state)
	.exec (err, vms) ->
		lab.fire(action, vms)
	  
	log.debug "lab=#{lab.name} event=vmStateChange vm=#{vm.uuid} (#{prev_state} -> #{vm.state})"



module.exports.register = mongoose.model 'Lab', LabSchema
