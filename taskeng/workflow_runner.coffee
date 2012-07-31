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

					@steps = [@active_step].concat(@steps)
					# TODO make delay configurable/or well defined constant
					@scheduled = new Date().getTime() + 5000

					return @runner.updateJob(this, true)

			on_error = @workflow_def.on_error
			return on_error BrokerHelper, @.data, @.on_error_helper if on_error

		re_insert = true

		# TODO add to the beginning of the list?
		if add_step?
			if typeof add_step is 'function'
				@.steps.push(add_step)
			else if typeof add_step is 'object'
				# FIXME validate listener object structure
				#      timeout, callback & on_expiry are mandatory
				log.debug "listener registered for job=#{@id}"

				# object won't get re-inserted to processing queue
				re_insert = false

				@runner.addListener @id, add_step

				# TODO once notification arrives add callback as next step, otherwise 
				#      on_expiry (if null, trigger error) and re-insert to processing
				#      queue

		# replace data
		@data = data

		# mark current step as processed (async.queue)
		@active_task_cb()

		# update and re-insert the job
		@runner.updateJob(this, true, re_insert)

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

	addStep: (step) ->
		@steps = [step].concat(@steps)

		@runner.updateJob(this)

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