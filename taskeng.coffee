os = require "os"
WorkflowRunner = require './taskeng/workflow_runner'
Backend = require "./taskeng/backend"

process.on 'SIGUSR1', () ->
	console.log 'got SIGUSR1'

backend = new Backend("#{os.hostname()}/#{process.pid}")

runner = new WorkflowRunner(backend)
runner.run()
