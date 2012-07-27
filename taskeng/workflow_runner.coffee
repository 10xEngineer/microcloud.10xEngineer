os = require 'os'
log = require("log4js").getLogger()

class WorkflowRunner
	constructor: (@backend) ->
		@interval = 250
		@keep_alive = 1000

		console.log @backend

		log.info "Initialized workflow runner #{@id}"

	run: ->
		setInterval @.run_ext, @interval
		setInterval @backend.register, @keep_alive

	run_ext: ->
		console.log '---'
		# FIXME setup workflow worker


module.exports = WorkflowRunner