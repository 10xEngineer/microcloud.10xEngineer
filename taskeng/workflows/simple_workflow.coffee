
class Job
	@constructor: (@worker, @workflow, @data)
		@task = @workflow.initial()

	cancel: ->
		# TODO


#
# node.js native workflow
#
# - use events from taskeng to signalize status
# - TODO how to serialize/deserialize objects
#


#
# sample worfklow
# ec2::create -> pool::allocate -> xxx::notify
#
class SimpleWorkflow
	@constructor: (@data) ->
		# some workflow specific data
		@chain = ["ec2::create", "pool::allocate", "xxx::notify", ""]

	run: (next) ->
		next null, "ec2::create"

	ec2_create: (next) ->
		# do something before before 
		next null, 

	initial: 
		"ec2::create"

	# TODO


	on_error: ->
		# executed on any error (fail by default, or change workflow)

