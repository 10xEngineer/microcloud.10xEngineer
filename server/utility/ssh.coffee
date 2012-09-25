module.exports = ->

log = require("log4js").getLogger()
Base = require "../labs/base"
EventEmitter = require('events').EventEmitter

spawn = require('child_process').spawn

class SSHExec extends Base
	@include EventEmitter

	constructor: (@target, @command, @options) ->
		@emitter = new EventEmitter()

	exec: () ->
		if typeof @target is 'string'
			dest = 
				user: "compile"
				host: @target
				port: 22
		else if typeof @target is 'object'
			dest = @target
		else
			raise "Invalid target specification"

		@term = spawn("ssh", ["#{dest.user}@#{dest.host}", "-p #{dest.port}", @command])

		@term.stdout.on 'data', (data) =>
			@emitter.emit 'data', data

		@term.stderr.on 'data', (data) =>
			@emitter.emit 'data', data

		@term.on 'exit', (data) =>
			if data == 0
				@emitter.emit 'end'
			else
				@emitter.emit 'failed', 

		@term.on 'close', (data) =>

module.exports.ssh_exec = (target, command, options = {}) ->
	ssh = new SSHExec(target, command, options)

	ssh.exec()

	return ssh.emitter
