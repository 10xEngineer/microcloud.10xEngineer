module.exports = ->

log = require("log4js").getLogger()
child_process = require "child_process"
_ = require "underscore"

# --------------------------------------------------------------------------------------------------------------------------------------------------------
#
#  Spawn a command line process, and stream the feedback back to the calling client
#
# =========================================================================================================================================================

child_process.spawn = _.wrap(child_process.spawn, (func) ->
	# We have to strip arguments[0] out, because that is the function
  	# actually being wrapped. Unfortunately, 'arguments' is no real array,
  	# so shift() won't work. That's why we have to use Array.prototype.splice 
  	# or loop over the arguments. Of course splice is cleaner. Thx to Ryan
  	# McGrath for this optimization.
	args = Array::slice.call(arguments, 0)
	log.debug "calling cli command with args: " + args

	# Call the wrapped function with our now cleaned args array
  	#TODO: Fix why apply() doesn't work
	childProcess = func.apply(this, args)
	childProcess.stdout.on "data", (data) ->
		process.stdout.write "" + data

	childProcess.stderr.on "data", (data) ->
		process.stderr.write "" + data

	childProcess
)

# execute the following cmds on the appropriate server (note this is also for container management - need to duplicate this for container level)

module.exports.spawn_command = (server, cmd, args) ->
	log.debug "spawn cli cmd: " + cmd + " " + args
	child = child_process.spawn(cmd, args, (error, stdout, stderr) ->
		log.debug "stdout: " + stdout
		log.debug "stderr: " + stderr
		if error isnt null
			log.debug "returning error"
			log.debug "exec error: " + error
			error
		else
			log.debug "returning stdout"
	)
	child

# execute the following cmds on the appropriate server (note this is also for container management - need to duplicate this for container level)

module.exports.execute_command = (server, cmd, args, callback) ->
	full_cmd = cmd + " " + args.join(" ")
	log.debug "execute cli cmd: " + full_cmd
	child = child_process.exec(full_cmd, (error, stdout, stderr) ->
		log.debug "stdout: " + stdout
		log.debug "stderr: " + stderr
		if error isnt null
			log.debug "returning error"
			log.debug "exec error: " + error
			callback error + stderr
		else
			log.debug "returning stdout"
			callback stdout
	)
	child

# Execute a command and stream the results back to the requester, also shut down the command when the client disconnects

module.exports.call_cli = (req, res, next) ->
	tail_child = execute_command(localhost, req.params.cmd, req.params.args.split(" "),
		cwd: "." or req.params.workingdir
	, (output) ->
		res.send output
	)
	tail_child.stdout.on "data", (data) ->
		res.send "" + data
