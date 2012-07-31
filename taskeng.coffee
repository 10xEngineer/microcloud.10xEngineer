#
# TaskEngine proof-of-concept
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

zmq = require "zmq"
os = require "os"
restify = require "restify"
WorkflowRunner = require "./taskeng/workflow_runner"
Backend = require "./taskeng/backend"

# service connector

# backend
backend = new Backend("#{os.hostname()}/#{process.pid}")
runner = new WorkflowRunner(backend)

# TODO load workfloads
runner.register require("./taskeng/workflow/simple_workflow")

# initial 0mq is only way how to submit job (using REQ only as it confirm only
# if the job has been accepted or not)
url = "ipc:///tmp/taskeng"
socket = zmq.socket "rep"
socket.identity = "taskeng/#{process.pid}"
socket.bind(url)

socket.on 'message', (data) ->
	# FIXME process real data
	_data = 
		workflow: "SimpleWorkflow"
		options:
			scheduled: new Date().getTime() + 5000
			timeout: 60000
		data: {}

	job = runner.createJob(_data)

	reply = 
		status: "ok"
		job_id: job.id

	socket.send JSON.stringify(reply)

# TODO use SIGUSR1 & SIGUSR2 for internal diagnostics
process.on 'SIGUSR1', () ->
	console.log 'got SIGUSR1'

runner.run()

# task engine HTTP API
api = require "./taskeng/api/server"
api.createServer(runner)

