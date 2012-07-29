os = require "os"
log = require("log4js").getLogger()
async = require "async"

worker = (task, cb) ->
	console.log '-- job received'
	console.log task

	# TODO getJob
	
class Job
	constructor: (@id, @data) ->
		@state = "created"
		@timeout = 10000

		@created_at = new Date().getTime()
		@.touch()

	expired: ->
		if (@updated_at + @timeout) > new Date().getTime()
			return false
		else
			return true

	touch: ->
		@updated_at = new Date().getTime()

class WorkflowRunner
	constructor: (@backend) ->
		@interval = 2500
		@keep_alive = 1000
		@concurrency = 10
		@id = "#{os.hostname()}:#{process.pid}"

		@queue = async.queue(worker, @concurrency)

		log.info "Initialized workflow runner #{@id}"

	createJob: (data) ->
		# TODO accepts job data as they are (add validation)

		job = new Job(@backend.generate_id(), data)

		log.debug "job=#{job.id} accepted"

		# TODO kick off the job

		# TODO replace with instance
		job.id


	run: ->
		setInterval @.run_ext, @interval
		setInterval @backend.register, @keep_alive

	run_ext: ->
		# find expired jobs
		@backend.staleJobs (job) ->
			console.log "job=#{job.id} expired"

		console.log '---'
		# FIXME setup workflow worker


module.exports = WorkflowRunner