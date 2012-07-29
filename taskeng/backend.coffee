log = require("log4js").getLogger()
uuid = require "node-uuid"

# TODO Backend should be abstract base class
class Backend
	constructor: (@id) ->
		@jobs = {}

	register: ->
		# FIXME register worker

	createJob: (job) ->
		# TODO add optional callback
		@jobs[job.id] = job

		job

	removeJob: (job_id) ->
		# TODO add optional callback
		delete @jobs[job_id]

	staleJobs: (cb) ->
		for job_id, job of @jobs
			if job.expired()
				cb(job)

	generate_id: ->
		uuid.v4()


module.exports = Backend