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
# `step_name = (helper, data, next) ->`
#
# * `helper` is a helper providing TaskEngine-enabled implementation of the most used integrations
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
#
# Sub Jobs are used for gateway/converge kind of logic. Step responsible for gateway logic fires 
# all necessary tasks using `helper.createSubJob data.id, jobData` same as with create job and 
# registers next step as object with type `converge`.
#
# Only after all child jobs finish/or expire the job can continue. Job data of all sub-jobs are 
# stored under the job data.NameOfTheSubJobsWorkflow array based on the job end-state -
# completed, failed or expired. It's jobs responsible to process it, or remove it.
#
# Example:
#
# { workflow: 'SimpleWorkflow',
#  id: '94e34b5f-28f8-4d37-af92-58ad46f4e3f3',
#   protected: 3,
#   SecondSimpleWorkflow: {
#		completed: [ { workflow: 'SecondSimpleWorkflow',
#        options: [Object],
#        say: 'hi!',
#        id: 'eb47a13e-c80a-4f65-8da2-85d9d06816ab' },
#      { workflow: 'SecondSimpleWorkflow',
#        options: [Object],
#        say: 'hi!',
#        id: 'f807bed7-248a-4249-93ed-71c8d1f3d21a' },
#      { workflow: 'SecondSimpleWorkflow',
#        options: [Object],
#        say: 'hi!',
#        id: '6fa2f4c6-83ab-4d1b-9596-20b03227b96a' } ]
#		failed: [],
#		expired: []}
#   event: [Function] }
#
# Internal/external notifications can be used as events for job flow using listner type 
# `subscribe`, specifying selector used to match all incoming notification for as long as the 
# listener is active.
#
# Example:
# 	next null, data,
#		type: "subscribe",
#		timeout: 60000
#		# selector gets evaluated on each notification
#		selector: (object, message, next) ->
#			console.log '--- notification evaluation'
#			# mark notification as accepted
#			next()
#		# callback only on those we select (TODO how)
#		callback: it_got_notification
#		on_expiry: something_expired
#
# helpers
# 0mq - runs within task engine core (provides timeouts, throttling, etc.)
# 


# sample use of broker service
dummy_ping = (helper, data, next) ->
	req = helper.dispatch 'dummy', 'ping', {}
	req.on 'data', (message) ->
		console.log '-- broker response'

		next null, data
	req.on 'error', (message) ->
		console.log '-- broker failed'

		next message.reason


# sample integration with microcloud
pool_allocate = (helper, data, next) ->
	url = "/pools/#{data.pool_name}/nodes"
	data =
		server_id: data.server.id

	req = helper.post url, data, (err, req, res, obj) ->
		if err
			next res

		next null, data

# sample code only step
just_code = (helper, data, next) ->
	if data.verbose == true
		console.log '-- just_code output'
		data.verbose = false

	next null, data

fail_twice = (helper, data, next) ->
	if data.protected?
		data.protected++
	else
		data.protected = 1

	unless data.protected > 2
		return next "failed on first execution", data

	next null, data

# demostrate how to adjust job flow on runtime
custom_flow = (helper, data, next) ->
	console.log '-- STEP: custom flow'
	next null, data, just_ping

just_ping = (helper, data, next) ->
	console.log '-- ping (not part of original flow)'

	next null, data

# registered callback listener and postpone the execution (expiry timeout not affected though)
wait_for_something = (helper, data, next) ->
	console.log "-- STEP: waiting for some external magic to happen"

	# do some logic and pass job _id
	# job id is `data.id`

	next null, data, 
		type: "listener"
		timeout: 30000
		callback: got_something
		on_expiry: something_expired

converge_example = (helper, data, next) ->
	# FIXME trigger subjobs


	for num in [1..3] 
		jobData = 
			workflow: "SecondSimpleWorkflow"
			options:
				scheduled: new Date().getTime() + 3000*num
			say: "hello"

		helper.createSubJob data.id, jobData, (err) ->
			if err
				console.log "--- SUBJOB ERR: #{err}"

	console.log '-- waiting for all sub-jobs to finish'

	next null, data,
		type: "converge",
		timeout: 60000
		callback: it_converged
		on_expiry: something_expired

it_converged = (helper, data, next) ->
	console.log '-IT CONVERGED!'

	next null, data

something_expired = (helper, data, next) ->
	console.log '--DOH: a listener expired'

	next null, data

got_something = (helper, data, next) ->
	console.log '-HURRAY: got something'
	console.log data.event

	next null, data

subscribe_to_something = (helper, data, next) ->
	console.log '--- subscribe to something'

	next null, data,
		type: "subscribe",
		timeout: 60000
		# selector gets evaluated on each notification
		selector: (object, message, next) ->
			console.log '--- notification evaluation'

			if /^vm:/.test(object)
				next()
		# callback only on those we select (TODO how)
		callback: it_got_notification
		on_expiry: something_expired

it_got_notification = (helper, data, next) ->
	console.log '---HURRAY! notification '
	console.log data.notification

	next null, data

on_error = (helper, data, next, err) ->
	console.log '-- it failed'

	recover = false
	if recover
		next null, data, custom_flow

	next null, data

# TODO shared logic
class SimpleWorkflow
	constructor: () ->
		step1 =
			step: fail_twice
			max_retries: 2

		# wait_for_something

		return {
			# converge_example
			flow: [step1, dummy_ping, just_code, subscribe_to_something]
			on_error: on_error
			timeout: 120000
		}

module.exports = SimpleWorkflow