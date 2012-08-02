#
# balance lab workflow
#
log = require("log4js").getLogger()

on_error = (bus, data, next, err) ->
	log.error "lab provisioning failed TODO"

# get the current lab's operational state
get_lab = (bus, data, next) ->
	lab = data.lab.name

	bus.get "/labs/#{lab}", (err, req, res, lab) ->
		if err
			return next err

		data.lab = lab
		next null, data

verify_vms = (bus, data, next) ->
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

allocate_vms = (bus, data,next) ->
	# TODO pass pool name
	# FIXME allocation is performed in series (sub-jobs for the rescue)

	pool = data.lab.pool

	data = 
		lab: data.lab.name
		vms: data.launch_vms

	url = "/pools/#{pool}/allocate"

	console.log url 
	bus.post url, data, (err, req, res, obj) ->
		if err
			return next res

		delete data.launch_vms

		return next null, data

# TODO wait for everything to become operational
# 

ping = (bus, data, next) ->
	bus.get '/ping', (err, req, res, obj) ->
		if err
			return next res

		next null, obj

class BalanceLabWorkflow
	constructor: () ->
		return {
			flow: [verify_vms, allocate_vms]
			on_error: on_error
			timeout: 300000
		}

module.exports = BalanceLabWorkflow