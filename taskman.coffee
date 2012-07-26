#
# task manager proof-of-concept
#

# TODO 
# TODO store task
# TODO periodically poll task for expiry
# TODO get all sub-tasks (parallel execution)
# TODO serial execution via zadd
# DONE class task

# task format o:domain:type:uuid[:subtask]

redis 	= require("redis").createClient()
uuid 	= require "node-uuid"

DEFAULT_TIMEOUT = 60000

class Task
	constructor: (@state='new', @timeout=DEFAULT_TIMEOUT, @retry = 1, @data = {}) ->
		@type = @constructor.name
		@created_at = new Date().getTime()

		@.generate_id
		@.touch()

	fire: (event, data) ->
		console.log 'fire'

	touch: ->
		@updated_at = new Date().getTime()

	perform: ->
		throw "Not implemented"

	@generate_id: -> 
		uuid.v1()

	# closest to static method
	@test: ->
		console.log '--- a'	

class Workflow
	constructor: (@chain, @timeout=DEFAULT_TIMEOUT) ->

	failed: ->
		# failed callback


class SimpleTask extends Task
	constructor: (@state='created', @timeout=DEFAULT_TIMEOUT, @data = {}) ->
		super(@state, @timeout, @data)

	perform: ->
		# launch ec2 instance

	succeed: ->
		# finished

	failed: ->
		# failed

	expired: ->
		# expired
		

# update logic


c1 = ->
	console.log SimpleTask.generate_id()

setInterval c1, 1000