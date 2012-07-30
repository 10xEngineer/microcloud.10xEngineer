os = require "os"
log = require("log4js").getLogger()
async = require "async"
_ = require "underscore"
broker = require "../server/broker"
Base = require "../server/labs/base"
EventEmitter = require('events').EventEmitter

worker = (task, job_helper) ->
	console.log "-- job received #{task}"

	job_helper()

class BrokerHelper
	constructor: () ->

	@dispatch: (service, method, options) ->
		return broker.dispatch service, method, options

class Job extends Base
	@include EventEmitter

	constructor: (@id, workflow, @data) ->
		@state = "created"

		@workflow_def = workflow()
		@steps = @workflow_def.flow
		@timeout = @workflow_def.timeout || 30000
		@scheduled = null

		@active_task_cb = null
		@active_step = null

		@retries = 0

		@runner = null

		@created_at = new Date().getTime()
		@.touch()

		EventEmitter.call @

		# TODO review - part of initial event originated processing
		#@.on 'start', @.start

	nextStep: ->
		return @steps.shift()

	next_helper: (err, data, add_step = null) =>
		console.log '-- JOB: next_helper called from task'

		if err
			console.log '-JOB: next_helper err triggered'

			if @active_step.max_retries?
				max_retries = Math.round(@active_step.max_retries)

				if @retries < max_retries
					@retries++	
					console.log "-JOB: retrying current step (#{@retries})"

					# TODO add delay of 5 seconds or something like this?
					return @active_step.step BrokerHelper, @.data, @.next_helper

			on_error = @workflow_def.on_error
			return on_error BrokerHelper, @.data, @.on_error_helper if on_error

		# TODO add to the beginning of the list?
		if add_step?
			@.steps.push(add_step)

		# replace data
		@data = data

		# mark current step as processed (async.queue)
		@active_task_cb()

		# update and re-insert the job
		@runner.updateJob(this, true)

	on_error_helper: (err, data, add_step = null) =>
		if err
			console.log '-JOB: on_error failed'

		console.log '-JOB: on_error next helper triggered'

		if add_step
			@.steps.push(add_step)
		else
			@.steps = []

		@active_task_cb()
		@runner.updateJob(this)

	start: ->
		console.log '--- start accepted'
		console.log @

	expired: ->
		# total workflow run time is limited by @timeout
		if (@created_at + @timeout) > new Date().getTime()
			return false
		else
			return true

	available: ->
		return 0 unless @scheduled?

		diff = @scheduled - new Date().getTime()
		if diff <= 0
			@scheduled = null
			return 0

		return diff

	touch: ->
		@updated_at = new Date().getTime()

		return @

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

		job = new Job(@backend.generate_id(), workflow, data)
		job.scheduled = new Date().getTime() + 5000
		job.runner = this

		@.updateJob(job)
		log.debug "job=#{job.id} accepted"

		# TODO move to queue worker
		#job.emit 'start'

		# TODO kick off the job

		# TODO replace with instance
		job.id

	removeJob: (job) ->
		@backend.removeJob(job)

	updateJob: (job, clear = false) ->
		if clear
			job.active_task_cb = null
			job.active_step = null
			job.retries = 0

		@backend.updateJob(job)
		@queue.push job.id

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

		console.log "--- jobs count: #{_.keys(@backend.jobs).length} / queue size: #{@queue.length()} / tasks executed : #{@task_count}"

	register: (workflow_klass) ->
		# TODO validate
		@workflows[workflow_klass.name] = workflow_klass

module.exports = WorkflowRunner