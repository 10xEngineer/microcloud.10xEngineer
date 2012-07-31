#
# Sample Workflow
#
# Worfklow is defined as named function returning hash with following structure
# {
#			flow: [task1, task2, task3]
#			on_error: on_error_fce
#			timeout: 30000
#		}
#
# * `flow` represents preset array of functions to perform
# * `on_error` is a callback to be executed in case job flow can't be restored (ie. 
#    pernament error)
# * `timeout` maximum time for workflow to run
#
# Workflow step
#
# `step_name = (bus, data, next) ->`
#
# * `bus` is a helper providing TaskEngine-enabled implementation of the most used integrations
# * `data` job data
# * `next` callback
#
# `next(err, data, add_step = null)`
# 
# * `err` - indicates the step failed (it can be retried; if it fails pernamently it does
#           trigger workflow's `on_error` callback)
# * `data` - updated job data, will replace original
# * `add_step` - if provided, WorkflowRunner will place provided step to the end of the job's
#                execution queue
#
# Job is the instance of workflow
#
# * `@scheduled` to start execution after given timestamp (is resetted every-time scheduled 
#                is activated).

# helpers
# 0mq - runs within task engine core (provides timeouts, throttling, etc.)
# 


# sample use of broker service
dummy_ping = (bus, data, next) ->
	req = bus.dispatch 'dummy', 'ping', {}
	req.on 'data', (message) ->
		console.log '-- broker response'

		next null, data
	req.on 'error', (message) ->
		console.log '-- broker failed'

		next message.reason


# sample integration with microcloud
pool_allocate = (bus, data, next) ->
	url = "/pools/#{data.pool_name}/nodes"
	data =
		server_id: data.server.id

	req = bus.post url, data
	req.on 'data', (response) ->
		next null, data

	req.on 'error', (response) ->
		next response.reason

# sample code only step
just_code = (bus, data, next) ->
	if data.verbose == true
		console.log '-- just_code output'
		data.verbose = false

	next null, data

fail_twice = (bus, data, next) ->
	if data.protected?
		data.protected++
	else
		data.protected = 1

	unless data.protected > 2
		return next "failed on first execution", data

	next null, data

# demostrate how to adjust job flow on runtime
custom_flow = (bus, data, next) ->
	console.log '-- STEP: custom flow'
	next null, data, just_ping

just_ping = (bus, data, next) ->
	console.log '-- ping (not part of original flow)'

	next null, data

on_error = (bus, data, next, err) ->
	console.log '-- it failed'

	recover = false
	if recover
		next null, data, custom_flow

	next null, data

# TODO shared logic
# TODO how to override timeout
class SimpleWorkflow
	constructor: () ->
		step1 =
			step: fail_twice
			max_retries: 2

		return {
			flow: [step1, just_code, dummy_ping]
			on_error: on_error
			timeout: 30000
		}

module.exports = SimpleWorkflow