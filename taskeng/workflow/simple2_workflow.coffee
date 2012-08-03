#
# SecondSimpleWorkflow - used to test sub-jobs
#

a_step = (bus, data, next) ->
	next null, data

on_error = (bus, data, next, err) ->
	console.log '---ON ERROR simple2'
	console.log err

	next null, data

class SecondSimpleWorkflow
	constructor: () ->
			return {
				flow: [a_step]
				on_error: on_error
				timeout: 15000
			}

module.exports = SecondSimpleWorkflow