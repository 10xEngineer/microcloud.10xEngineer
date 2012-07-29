os = require "os"
log = require("log4js").getLogger()
async = require "async"
Base = require "../server/labs/base"
EventEmitter = require('events').EventEmitter

worker = (task, cb) ->
	console.log '-- job received'
	console.log task

	# TODO getJob
	
class Job extends Base
	@include EventEmitter

	constructor: (@id, @data) ->
		@state = "created"
		@timeout = 10000

		@created_at = new Date().getTime()
		@.touch()

		EventEmitter.call @

		@.on 'start', @.start

	start: ->
		console.log '--- start accepted'
		console.log @

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

		@backend.createJob(job)
		log.debug "job=#{job.id} accepted"

		# TODO move to queue worker
		#job.emit 'start'

		# TODO kick off the job

		# TODO replace with instance
		job.id

	run: ->
		@.setUpdateInterval(@.run_ext, @interval)
		#setUpdateInterval(@backedng)
		#setInterval @.run_ext, @interval
		#setInterval @backend.register, @keep_alive

	setUpdateInterval: (fce, timeout) ->
		callback = fce.bind(this)
		setInterval(callback, timeout)

	run_ext: ->
		# find expired jobs
		@backend.staleJobs (job) =>
			console.log "job=#{job.id} expired"

			@backend.removeJob(job.id)

		console.log '---'
		# FIXME setup workflow worker


module.exports = WorkflowRunner