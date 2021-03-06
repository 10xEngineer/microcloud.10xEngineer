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
	name: { type: String }
	vm: {type: ObjectId, ref: 'Vm'}
	uuid: { type: String }
	# TODO attributes
	# TODO networking details
})

LabSchema = new mongoose.Schema({
	# TODO link to owner (user/domain) + add it to compound index (below)
	name: { type: String, required: true }

	# TODO define only default pools for each resource class
	pools: {
		compute: {type: ObjectId, ref: 'Pool'},
		storage: {type: ObjectId, ref: 'Pool'},
		network: {type: ObjectId, ref: 'Pool'},
	}

	token: { type: String, unique: true }
	repo: String

	current_definition: {type: ObjectId, ref: 'Definition', xauto_populate: true}

	operational: {
		vms: [AllocatedVMSchema]
		# TODO storage
		# TODO networks
	}

	# TODO lab attributes is just a temporary mechanism how to store 
	#      data in lab-context and make them available to the underlying
	#      components.
	#      Initial use-case is chef-level resourec to retrive data as a
#      replacement of search/databag.
	attrs: {
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

			"pending"

		failed: (lab, vms) ->
			"failed"

	# TODO pending does not really represent true state
	"pending":
		vm_locked: (lab, vms) ->
			log.debug "lab=#{lab.name} received vm_locked"

			"pending"

		vm_running: (lab, vms) ->
			log.debug "lab=#{lab.name} received vm_running"

			"pending"

		vm_available: (lab, active_vms) =>
			# TODO make re-usable (vm_running, vm_allocated)
			# FIXME this should be handled by lab workflow
			#vm_count = lab.definition.vms.length

			#if vm_count == active_vms.length
			#
			# FIXME come up with the lab lifecycle
			return "pending"


		confirm: (lab) ->
			log.debug "lab=#{lab.name} state=confirmed"
			"available"

	"available":
		vm_destroyed: (lab, vms) ->
			# FIXME implement
			# FIXME move to other state "pending" is now temporary

			"terminating"

		vm_stopped: (lab, vms) ->
			"available"

	# TODO in most cases lab does not terminate just because single VM is destroyed
	"terminating":
		destroy: (lab) ->
			"destroyed"

	"failed": {}

	"destroyed": {}

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

	if vm.state is 'available'
		allocated_vm = 
			name: vm.vm_name
			vm: vm._id
			uuid: vm.uuid

		lab.operational.vms.push(allocated_vm)
		lab.save (err) ->
			if err 
				log.warn "unable to update(1) lab=#{lab.name} vm=#{vm.uuid} err=#{err}"
			else
				log.debug "vm=#{vm.uuid} added to lab=#{lab.name} operational list"

	findVm = (name, vms) ->
		for vm in vms
			index = vms.indexOf(vm)
			return index if vm.name == name

		return -1

	# TODO test once the VM lifecycle notifications are fixed
	# https://trello.com/card/lxc-dnsmasq-does-not-maintain-ip-address-lease-based-on-actual-container-state/50067c2712a969ae032917f4/57
	if vm.state is 'stopped' || vm.state is 'destroyed'
    	index = findVm vm.vm_name, lab.operational.vms

    	if index >= 0
    		lab.operational.vms.splice(index, 1)
    		lab.markModified("operational")
    		lab.save (err) ->
    			if err
    				log.warn "unable to update(2) lab=#{lab.name} for vm=#{vm.uuid} err=#{err}" 
	  
	log.debug "lab=#{lab.name} event=vmStateChange vm=#{vm.uuid} (#{prev_state} -> #{vm.state})"

module.exports.register = mongoose.model 'Lab', LabSchema
