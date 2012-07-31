os = require "os"
log = require("log4js").getLogger()
async = require "async"
_ = require "underscore"
broker = require "../server/broker"
Job = require "./job"

worker = (task, job_helper) ->
	console.log "-- job received #{task}"

	job_helper()

class BrokerHelper
	constructor: () ->

	@dispatch: (service, method, options) ->
		return broker.dispatch service, method, options

step_helper = (err, data, new_step = nil) ->
	console.log '-- step_help'


class WorkflowRunner
	constructor: (@backend) ->
		@interval = 2500
		@keep_alive = 1000
		@concurrency = 10
		@workflows = {}
		@id = "#{os.hostname()}:#{process.pid}"

		@queue = async.queue(@.runJob, @concurrency)

		@task_count = 0

		log.info "Initialized workflow runner #{@id}"

	createJob: (data) ->
		# FIXME accepts job data as they are (add validation)

		workflow = @workflows[data.workflow]
		options = data.options || {}

		job = new Job(@backend.generate_id(), workflow, data)

		job.scheduled = options.scheduled
		job.timeout = options.timeout
		job.runner = this

		@.updateJob(job)
		log.debug "job=#{job.id} accepted"

		# TODO replace with instance?
		job.id

	removeJob: (job) ->
		@backend.removeJob(job)

	addListener: (id, listener) ->
		@backend.addListener(id, listener)

	updateJob: (job, clear = false, insert = true) ->
		job.data.id = job.id
		
		if clear
			job.active_task_cb = null
			job.active_step = null

		@backend.updateJob(job)

		if insert
			@queue.push job.id

	processEvent: (job_id, data, cb) ->
		@backend.getListener job_id, (err, listener) =>
			if err
				return cb(err)

			# TODO refactor; ugly, but it's necessary to always retrieve latest
			#      job definition
			@backend.getJob job_id, (err, job) =>
				if err
					return cb(err)

				@backend.removeListener(job_id)
				cb(null)

				job.steps = [listener.callback].concat(job.steps)
				job.data.event = data

				@.updateJob(job)

	build_helper: (job, queue_cb) ->
		# TODO queue callback is used to indicate the job in progress
		#      works fine for single node, but needs re-thinking for cluster
		#      wide deployment
		# TODO workflow runner should instrument re-insertion to the async.queue
		job.queue_cb = queue_cb
		job.next_helper

	runJob: (job_id, cb) =>
		# find next task
		# re-queue the job 
		@backend.getJob job_id, (err, job) =>
			if err
				log.error "invalid job=#{job_id} reason=#{err}"
				return cb()

			log.debug "processing job=#{job_id}"

			if job.available() > 0
				# job is not yet scheduled for execution

				setTimeout () =>
					cb()
					@.updateJob(job)
				, job.available()

				return

			# TODO what to do if active_task_cb is already assigned? 

			next_step = job.nextStep()
			job.active_task_cb = cb

			if next_step
				@task_count++

				if typeof next_step is 'function'
					next =
						step: next_step
				else
					next = next_step

				job.active_step = next

				# TODO bus/BrokerHelper should be configurable
				next.step BrokerHelper, job.data, @.build_helper(job, cb)
			else
				run_time = new Date().getTime() - job.created_at
				console.log "-- job: #{job_id} finished in #{run_time} ms"
				# finish the task

				@.removeJob(job_id)
				cb()

	run: ->
		@.setUpdateInterval(@.run_ext, @interval)

	setUpdateInterval: (fce, timeout) ->
		callback = fce.bind(this)
		setInterval(callback, timeout)

	run_ext: ->
		# find expired jobs
		@backend.staleJobs (job) =>
			console.log "job=#{job.id} expired"

			@backend.removeJob(job.id)

		@backend.staleListeners (listener) =>
			console.log "listener=#{listener.id} expired"

			on_expiry = listener.on_expiry
			# get job
			# add on_expiry as next step

			@backend.getJob listener.id, (err, job) =>
				job.addStep(on_expiry)

				@backend.removeListener(listener.id)

		console.log "--- jobs: #{_.keys(@backend.jobs).length} / queue: #{@queue.length()} / tasks: #{@task_count}"

	register: (workflow_klass) ->
		# TODO validate
		@workflows[workflow_klass.name] = workflow_klass

module.exports = WorkflowRunner