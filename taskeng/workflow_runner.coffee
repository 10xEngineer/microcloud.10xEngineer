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

	createJob: (data, parent_id = null, cb) ->
		# FIXME it accepts job data as they are (add validation)

		workflow = @workflows[data.workflow]
		unless workflow?
			return cb(new Error("Undefined workflow '#{data.workflow}'"))

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
		cb null, job.id if cb?

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

	updateListener: (job_id, listener, type, data, cb = null) ->
		@backend.getJob job_id, (err, job) =>
			if err
				if cb?
					return cb(err)
				else
					return 

			if listener.type is 'converge'
				return unless job.subjobs.length == 0

			@backend.removeListener(job_id)
			cb(null) if cb

			job.steps = [listener.callback].concat(job.steps)
			job.data[type] = data

			@.updateJob(job)	

	processEvent: (job_id, parent, data, cb) ->
		@backend.getListener job_id, (err, listener) =>
			if err
				return cb(err)

			@.updateListener(job_id, listener, 'event', data)

	processNotification: (object, message) ->
		# each notification is validated against each subscriber's selector
		for job_id, subscriber of @backend.subscriptions
			subscriber.selector object, message, () =>

				# FIXME refactor to a single function shared with processEvent
				data = 
					object: object
					message: message

				@.updateListener(job_id, subscriber, 'notification', data)

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

			if next_step?
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

				# finish the task
				cb()

				job.data.state = 'completed' if job.data.state is 'created'
				log.debug "job=#{job_id} finished in time=#{run_time} ms with state=#{job.data.state}"

				if job.parent_id? 
					log.debug "sub job=#{job.id} notifies parent"

					@.updateParentJob job.parent_id, (err, parent_job, next) ->
						if err							
							log.error "unable to retrieve parent job=#{job.parent_id} reason=#{err}"
							return

						wf_name = job.workflow.name

						unless parent_job.data[wf_name]
							parent_job.data[wf_name] =
								completed: []
								failed: []
								expired: []

						parent_job.data[wf_name][job.data.state].push(job.data)

						parent_job.removeChild(job)
						next parent_job

					@.processEvent job.parent_id, null, job.data, (err) ->
						log.error "job=#{job.parent_id} child-to-parent notification failed; reason=#{err}"

				@.removeJob(job_id)
				

	run: ->
		@.setUpdateInterval(@.run_ext, @interval)

	setUpdateInterval: (fce, timeout) ->
		callback = fce.bind(this)
		setInterval(callback, timeout)

	run_ext: ->
		# find expired jobs
		@backend.staleJobs (job) =>
			console.log "job=#{job.id} expired"

			job.data.state = 'expired'
			job.steps = []

			@.updateJob(job, true)

			# remove listener (in cases when job expires before the listener)
			if @backend.hasListener(job.id)
				@backend.removeListener(job.id)

		@backend.staleListeners (listener) =>
			console.log "listener=#{listener.id} expired"

			on_expiry = listener.on_expiry

			@backend.getJob listener.id, (err, job) =>
				job.data.state = 'expired'
				job.steps = [on_expiry]

				@.updateJob(job, true)
				@backend.removeListener(job.id)

		log.debug "stats: jobs=#{_.keys(@backend.jobs).length} queue=#{@queue.length()} listeners=#{_.keys(@backend.listeners).length} subscribers=#{_.keys(@backend.subscriptions).length} tasks=#{@task_count}"

	register: (workflow_klass) ->
		# TODO validate
		@workflows[workflow_klass.name] = workflow_klass

module.exports = WorkflowRunner