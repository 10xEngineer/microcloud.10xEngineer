#
# Workflow Runner Backend
#
# Provides storage/basic logic for workflow runner. Current implementation is in-memory 
# only. 
#
# Acts as registry for
# 
# * jobs - hash of all jobs handled by current workflow runner
# * listeners - hash of all listeners registered within current worflow runner
#
# TODO workflow runner periodically registers itself (keep-alive). Master instance (TODO) 
# re-assignes jobs to other runner if particular one stops pinging.
# TODO job persistency - all job attributes (flow, data) needs to be updated after each
# individual step to allow almost seamless failover
# TODO each workflow runner acts as a notification subscriber, evaluating notifications 
# with active registrations (another registry next to jobs and listeners). Notification part 
# should be part of workflow runner, but moved out later (number of notifications is going to 
# be significantly higher compared to number of processed job steps).
#

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

	getListener: (id, next) ->
		listener = @listeners[id]

		if listener
			next null, listener
		else
			next "No listener found."

	staleListeners: (cb) ->
		for job_id, listener of @listeners
			if (listener.created_at + listener.timeout < new Date().getTime())
				cb(listener)

	generate_id: ->
		uuid.v4()


module.exports = Backend