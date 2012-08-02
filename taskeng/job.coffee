Base = require "../server/labs/base"
EventEmitter = require('events').EventEmitter
log = require("log4js").getLogger()

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
				if add_step.type is 'listener'
					# FIXME validate listener object structure
					#      timeout, callback & on_expiry are mandatory
					log.debug "listener registered for job=#{@id}"

					# object won't get re-inserted to processing queue
					re_insert = false

					@runner.addListener @id, add_step
					
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

module.exports = Job