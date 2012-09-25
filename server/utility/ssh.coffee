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
		@term = spawn("ssh", [@target, @command])

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
