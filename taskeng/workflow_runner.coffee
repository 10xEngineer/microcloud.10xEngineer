os = require "os"
log = require("log4js").getLogger()
async = require "async"
_ = require "underscore"
Job = require "./job"
BrokerHelper = require "./helper"

class WorkflowRunner
	constructor: (@backend) ->
		@interval = 2500
		@keep_alive = 1000
		@concurrency = 10
		@workflows = {}
		@id = "#{os.hostname()}:#{process.pid}"

		@queue = async.queue(@.runJob, @concurrency)

		@task_count = 0

		@helper = new BrokerHelper @

		log.info "Initialized workflow runner #{@id}"

	createJob: (data, parent_id = null) ->
		# FIXME it accepts job data as they are (add validation)

		workflow = @workflows[data.workflow]
		options = data.options || {}

		job = new Job(@backend.generate_id(), workflow, data, parent_id)

		job.scheduled = options.scheduled
		job.timeout = options.timeout || workflow().timeout
		job.runner = this

		if parent_id?
			@.updateParentJob parent_id, (err, parent_job, next) ->
				if err
					log.error "unable to update parent job=#{parent_id} reason=#{err}"
					return

				parent_job.addChild(job)
				next parent_job

		@.updateJob(job)
		log.debug "job=#{job.id} with workflow=#{job.workflow.name} accepted"

		# TODO replace with instance?
		job.id

	removeJob: (job) ->
		@backend.removeJob(job)

	addListener: (id, listener) ->
		@backend.addListener(id, listener)

	updateParentJob: (job_id, callback) ->
		@backend.getJob job_id, (err, job) =>
			save = (updated_job) =>
				@.updateJob(updated_job, false, false)

			callback err, job, save

	updateJob: (job, clear = false, insert = true) ->
		job.data.id = job.id
		
		if clear
			job.active_task_cb = null
			job.active_step = null

		@backend.updateJob(job)

		if insert
			@queue.push job.id

	processEvent: (job_id, parent, data, cb) ->
		@backend.getListener job_id, (err, listener) =>
			if err
				return cb(err)

			@backend.getJob job_id, (err, job) =>
				if err
					return cb(err)

				if listener.type is 'converge'
					return unless job.subjobs.length == 0

				@backend.removeListener(job_id)
				cb(null) if cb

				job.steps = [listener.callback].concat(job.steps)
				job.data.event = data

				@.updateJob(job)


	build_helper: (job, queue_cb) ->
		# TODO queue callback is used to indicate the job in progress
		#      works fine for single node, but needs re-thinking for cluster
		#      wide deployment
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

			if job.active_task_cb?
				log.warn "job=#{job_id} already has active step assigned; overriding"

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

				next.step @helper, job.data, @.build_helper(job, cb)
			else
				run_time = new Date().getTime() - job.created_at
				log.debug "job=#{job_id} finished in time=#{run_time} ms"
				# finish the task

				if job.parent_id? 
					log.debug "sub job=#{job.id} notifies parent"

					@.updateParentJob job.parent_id, (err, parent_job, next) ->
						if err							
							log.error "unable to retrieve parent job=#{job.parent_id} reason=#{err}"
							return

						wf_name = job.workflow.name

						parent_job.data[wf_name] = [] unless parent_job.data[wf_name]
						parent_job.data[wf_name].push(job.data)

						parent_job.removeChild(job)
						next parent_job

					@.processEvent job.parent_id, job.data, (err) ->
						log.error "job=#{job.parent_id} child-to-parent notification failed; reason=#{err}"

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

			@backend.getJob listener.id, (err, job) =>
				job.addStep(on_expiry)

				@backend.removeListener(listener.id)

		log.debug "stats: jobs=#{_.keys(@backend.jobs).length} queue=#{@queue.length()} listeners=#{_.keys(@backend.listeners).length} tasks=#{@task_count}"

	register: (workflow_klass) ->
		# TODO validate
		@workflows[workflow_klass.name] = workflow_klass

module.exports = WorkflowRunner