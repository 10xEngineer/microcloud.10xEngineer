#
# balance lab workflow
#
# TODO ?? chef run
# TODO 
#
log = require("log4js").getLogger()

on_error = (helper, data, next, err) ->
	log.error "-- XXX --- lab provisioning failed TODO"

	next null, data

# get the current lab's operational state
get_lab = (helper, data, next) ->
	lab = data.lab.name

	helper.get "/labs/#{lab}", (err, req, res, lab) ->
		if err
			return next err

		data.lab = lab
		next null, data

verify_vms = (helper, data, next) ->
	# TODO find the diff in VMs  (run-list, attributes, etc.)

	current_vms = {}
	for vm in data.lab.operational.vms
		current_vms[vm.name] = vm

	launch_vms = []
	terminate_vms = []

	for vm_name, vm of data.definition.vms
		unless current_vms.vm_name?
			launch_vms.push(vm)

	for vm_name, vm of data.lab.operational.vms
		unless data.definition.vms.vm_name?
			terminate_vms.push(vm)

	data.launch_vms = launch_vms
	data.terminate_vms = terminate_vms

	next null, data

bootstrap_vms = (helper, data,next) ->
	for i of data.launch_vms
		bootstrap_data = 
			workflow: "VMAllocateWorkflow"
			lab: data.lab
			vm: data.launch_vms[i]

		helper.createSubJob data.id, bootstrap_data, (err) ->
			if err
				log.error "job=#{data.id} subJob workflow=#{bootstrap_data.workflow} failed reason=#{err.message}"

	next null, data,
		type: 'converge'
		timeout: 630000
		# TODO continue -> wait_for_lab (what exactly for?s)
		callback: dummy
		on_expiry: on_expiry_bootstrap

on_expiry_bootstrap = (helper, data, next) ->
	# FIXME implement
	console.log "--- LAB WORKFLOW boostrap on_expiry; couldn't allocate requested VMs"

	next null, data

dummy = (helper, data, next) ->
	# FIXME failed

	console.log '--- DUMMY'
	console.log "-- stats: completed: #{data.VMAllocateWorkflow.completed.length}"
	console.log "-- stats: failed: #{data.VMAllocateWorkflow.failed.length}"
	console.log "-- stats: expired: #{data.VMAllocateWorkflow.expired.length}"
	console.log "--- expected: #{data.VMAllocateWorkflow.completed.length}"
	console.log "--- expected: #{data.launch_vms.length}"

	if data.VMAllocateWorkflow.completed.length == data.launch_vms.length
		next null, data
	else 
		next "XYZ", data

wait_for_lab = (helper, data, next) ->
	next null, data, 
		type: "listener",
		timeout: 600000,
		callback: lab_allocated
		on_expiry: rollback

rollback = (helper, data, next) ->
	# FIXME implement
	next null, data

lab_allocated = (helper, data, next) ->
	# FIXME implement

	next null, data

# TODO wait for everything to become operational
# 

ping = (helper, data, next) ->
	helper.get '/ping', (err, req, res, obj) ->
		if err
			return next res

		next null, obj

class BalanceLabWorkflow
	constructor: () ->
		return {
			flow: [verify_vms, bootstrap_vms]
			on_error: on_error
			timeout: 900000
		}

module.exports = BalanceLabWorkflow