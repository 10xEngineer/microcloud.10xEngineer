#
# sample worfklow
# ec2::create -> pool::allocate -> xxx::notify
#
#class SimpleWorkflow
#	constructor: ->
#		# some workflow specific data
#		#@chain = ["ec2::create", "pool::allocate", "xxx::notify", ""]
#
#	@demo: ->
#		console.log '--demo'
#
#	on_error: ->
#		# executed on any error (fail by default, or change workflow)

#module.exports = SimpleWorkflow

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
		return {
			flow: [just_code, dummy_ping, custom_flow]
			on_error: on_error
			timeout: 30000
		}

module.exports = SimpleWorkflow