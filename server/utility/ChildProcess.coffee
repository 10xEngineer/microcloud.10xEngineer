child_process.spawn = underscore.wrap child_process.spawn, (func) ->
	Array::splice.call arguments, 0, 1
	childProcess = func.apply(this, args)
	childProcess.stdout.on "data", (data) ->
		process.stdout.write "" + data

	childProcess.stderr.on "data", (data) ->
		process.stderr.write "" + data

	childProcess
