#
# lab teardown workflow
#

stop_vms = (helper, data, next) ->
	vms = data.lab.operational.vms

	for vm in vms
		bootstrap_data = 
			workflow: "VMDestroyWorkflow"
			vm: vm

		helper.createSubJob data.id, bootstrap_data, (err) ->
			if err
				log.error "job=#{data.id} subJob workflow=#{bootstrap_data.workflow} failed reason=#{err.message}"

	next null, data,
		type: 'converge'
		timeout: 120000
		callback: vms_destroyed
		on_expiry: on_expiry

vms_destroyed = (helper, data, next) ->
	next null, data

on_expiry = (helper, data, next) ->
	next null, data

on_error = (helper, data, next, err) ->
  log.error "workflow=lab_teardown failed reason=#{err}"
  
  next null, data

class LabTeardownWorkflow
	constructor: () ->
		return {
			flow: [stop_vms]
			on_error: on_error
			timeout: 240000
		}

module.exports = LabTeardownWorkflow