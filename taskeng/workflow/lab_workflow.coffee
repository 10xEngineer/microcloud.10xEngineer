#
# balance lab workflow
#
log = require("log4js").getLogger()
processDependencies = require("./utils/resolve").processDependencies

on_error = (helper, data, next, err) ->
	log.error "-- XXX --- lab provisioning failed TODO"

	next null, data

vm_launch_list = (helper, data, next) ->
	launch_vms = []

	current_vms = {}
	for vm in data.lab.operational.vms
		current_vms[vm.name] = vm if vm?
		
	for index, vm of data.definition.vms
		vm_name = vm.name
		unless current_vms[vm_name]?
			launch_vms.push(vm)

	data.launch_vms = processDependencies(launch_vms)

	next null, data, get_batch

get_batch = (helper, data, next) ->

	batch = []

	for vm in data.launch_vms
		if vm.dependencies.length == 0
			batch.push(vm)
		else
			break

	if batch.length == 0 && data.launch_vms.length > 0
		return next new Error("Unable to launch lab! Can't satistify dependencies.")

	data.next_batch = batch

	next null, data, bootstrap_vms

bootstrap_vms = (helper, data, next) ->
	for i of data.next_batch
		bootstrap_data = 
			workflow: "VMAllocateWorkflow"
			lab: data.lab
			vm: data.next_batch[i]

		helper.createSubJob data.id, bootstrap_data, (err) ->
			if err
				log.error "job=#{data.id} subJob workflow=#{bootstrap_data.workflow} failed reason=#{err.message}"

	next null, data,
		type: 'converge'
		timeout: 630000
		callback: vms_ready
		on_expiry: on_expiry_bootstrap	

removeVM = (a_vm, vm_list) ->
	results = []

	for vm in vm_list
		dependencies = vm.dependencies
		vm.dependencies = []
		for dep in dependencies
			vm.dependencies.push(dep) unless dep.name == a_vm.name

		results.push(vm) unless vm.name == a_vm.name

	return results

vms_ready = (helper, data, next) ->
	vm_list = data.launch_vms
	# vms from next_batch are running
	for vm in data.next_batch
		vm_list = removeVM(vm, vm_list)

	data.launch_vms = vm_list

	if data.launch_vms.length == 0
		next null, data, lab_ready
	
	next null, data, get_batch

lab_ready = (helper, data, next) ->
	# FIXME lab should be ready and all vms bootstrapped
	# CONTINUE

	# TODO return to original lab temporary stats c
	next null, data, dummy

# --- old workflow ----

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
		current_vms[vm.name] = vm if vm?

	launch_vms = []
	terminate_vms = []


	#for vm_name, vm of data.lab.operational.vms
	#	unless data.definition.vms.vm_name?
	#		terminate_vms.push(vm)

	data.launch_vms = launch_vms
	#data.terminate_vms = terminate_vms

	next null, data

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

update_vms = (helper, data,next) ->
	# FIXME implement
	#       update existing VMs (ie. force the repository re-sync and chef-solo run)
	next null, data

# TODO probably not needed anymore
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
			#flow: [verify_vms, bootstrap_vms, update_vms]
			flow: [vm_launch_list]
			on_error: on_error
			timeout: 900000
		}

module.exports = BalanceLabWorkflow