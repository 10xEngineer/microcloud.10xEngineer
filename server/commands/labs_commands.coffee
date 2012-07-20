module.exports = ->

log = require("log4js").getLogger()
broker = require("../broker")

module.exports.create = (req, res, next) ->
	# FIXME not implemented
	#
	# 1. prepare git repository
	# 2. create lab object
	# 3. come up with name (provided or use auto-generated?)

	# evaluate requested action (create/clone)

	broker.dispatch 'git_adm', op, opts, (message) =>
		if message.status == 'ok'
			res.send {}
		else
			res.send 500, "doh!"


