module.exports = ->

log = require("log4js").getLogger()
pty = require("pty.js")
Base = require "./base"
EventEmitter = require('events').EventEmitter

class SSHExec extends Base
	@include EventEmitter

	constructor: (@target, @command, @options) ->
		@emitter = new EventEmitter()

	exec: () ->
		@term = pty.spawn("ssh", [@target, @command])

		@term.on 'data', (data) =>
			@emitter.emit 'data', data

		@term.on 'exit', (data) =>
			@emitter.emit 'end'

module.exports.ssh_exec = (target, command, options = {}) ->
	ssh = new SSHExec(target, command, options)

	ssh.exec()

	# TODO exec command
	ssh.emitter
