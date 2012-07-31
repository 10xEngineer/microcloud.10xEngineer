log = require("log4js").getLogger()
uuid = require "node-uuid"

# TODO Backend should be abstract base class
class Backend
	constructor: (@id) ->
		@jobs = {}
		@listeners = {}

	register: ->
		# FIXME register worker

	updateJob: (job) ->
		# TODO add optional callback
		@jobs[job.id] = job

		job.touch()

	getJob: (job_id, next) ->
		job = @jobs[job_id]

		if job
			next null, job
		else
			next "No job found."

	removeJob: (job_id) ->
		# TODO add optional callback
		delete @jobs[job_id]

	staleJobs: (cb) ->
		for job_id, job of @jobs
			if job.expired()
				cb(job)

	addListener: (id, listener) ->
		listener.id = id
		listener.created_at = new Date().getTime()
		@listeners[id] = listener

	removeListener: (id) ->
		delete @listeners[id]

	staleListeners: (cb) ->
		for job_id, listener of @listeners
			if (listener.created_at + listener.timeout < new Date().getTime())
				cb(listener)

	generate_id: ->
		uuid.v4()


module.exports = Backend