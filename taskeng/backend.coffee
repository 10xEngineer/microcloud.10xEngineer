log = require("log4js").getLogger()
uuid = require "node-uuid"

# TODO Backend should be abstract base class
class Backend
	constructor: (@id) ->
		@jobs = {}

	register: ->
		# FIXME register worker

	createJob: (job) ->
		@jobs[job.id] = job

		job

	staleJobs: (cb) ->
		for job_id, job of @jobs
			console.log "checking #{job_id}"
			if job.expired()
				cb(job)

	generate_id: ->
		uuid.v4()


module.exports = Backend