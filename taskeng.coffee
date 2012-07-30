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
		timeout: 30000

	job_id = runner.createJob(_data)

	reply = 
		status: "ok"
		job_id: job_id

	socket.send JSON.stringify(reply)

process.on 'SIGUSR1', () ->
	console.log 'got SIGUSR1'

runner.run()
