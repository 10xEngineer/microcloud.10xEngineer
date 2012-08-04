#
# balance lab workflow
#
log = require("log4js").getLogger()

on_error = (helper, data, next, err) ->
	log.error "lab provisioning failed TODO"

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

allocate_vms = (helper, data,next) ->
	# TODO pass pool name
	# FIXME allocation is performed in series (sub-jobs for the rescue)

	pool = data.lab.pool

	data = 
		lab: data.lab.name
		vms: data.launch_vms

	url = "/pools/#{pool}/allocate"

	console.log url 
	helper.post url, data, (err, req, res, obj) ->
		if err
			console.log '---- allocate failed'
			return next res

		delete data.launch_vms

		return next null, data

wait_for_lab = (helper, data, next) ->
	next null, data, 
		type: "listener",
		timeout: 60000,
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
			flow: [verify_vms, allocate_vms, wait_for_lab]
			on_error: on_error
			timeout: 300000
		}

module.exports = BalanceLabWorkflow