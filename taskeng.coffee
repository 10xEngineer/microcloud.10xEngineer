#
# TaskEngine proof-of-concept
#
# WARNING: it's proof-of-concept. it's considerably fragile and yet-to-be-finished.
#
# Additional topics
#
# TODO review the task handling logic and add callbacks where appopriate
# TODO backend as abstract definition with redis backend implementation
# TODO accept jobs over HTTP api
#      * limited (can only re-use predefined steps/tasks)
# TODO allow multiple job runners
#      * each runner registers and periodically updates 'last_seen_at' in redis
#      * all jobs are assigned to particular runner (to avoid race conditions)
#      * master process periodically checks all runners, if it exceeds timeout, 
#        reclaim the jobs
#      * maintain stats on individual runners
# TODO multi-tenancy
#      * maintain per-tenant stats (inserted jobs, processed tasks)
#      * sandbox individual job step executions (node's vm)
# TODO misc task improvements
#      * task expiry (follow retries configuration convention)
# TODO cancel job
# TODO sub jobs
#      * allow multiple listeners
#      * fanout mode (launch all - wait for them to finish)

log = require("log4js").getLogger()
zmq = require "zmq"
os = require "os"
restify = require "restify"
WorkflowRunner = require "./taskeng/workflow_runner"
Backend = require "./taskeng/backend"

redis = require "redis"
client = redis.createClient()

# service connector

# backend
backend = new Backend("#{os.hostname()}/#{process.pid}")
runner = new WorkflowRunner(backend)

# TODO load workfloads
runner.register require("./taskeng/workflow/simple_workflow")
runner.register require("./taskeng/workflow/simple2_workflow")
runner.register require("./taskeng/workflow/lab_workflow")
runner.register require("./taskeng/workflow/vm_allocate")

# initial 0mq is only way how to submit job (using REQ only as it confirm only
# if the job has been accepted or not)
url = "ipc:///tmp/taskeng"
socket = zmq.socket "rep"
socket.identity = "taskeng/#{process.pid}"
socket.bind(url)

socket.on 'message', (message) ->
	data = JSON.parse message

	job = runner.createJob data, null, (err, job_id) ->
		if err
			console.log err
			return socket.send JSON.stringify
				status: "error"
				reason: err.message

		reply = 
			status: "ok"
			job_id: job_id

		socket.send JSON.stringify(reply)

# redis pubsub integration
client.on 'psubscribe', (channel, count) ->
	log.info "subscribed to redis notifications"

client.on 'pmessage', (pattern, channel, message) ->
	runner.processNotification channel, JSON.parse message

client.psubscribe "*"

# TODO use SIGUSR1 & SIGUSR2 for internal diagnostics
process.on 'SIGUSR1', () ->
	# FIXME dump statistics
	console.log 'got SIGUSR1'

process.on 'SIGUSR2', () ->
	console.log 'got SIGUSR2'

runner.run()

# task engine HTTP API
api = require "./taskeng/api/server"
api.createServer(runner)

