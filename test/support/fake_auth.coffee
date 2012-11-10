called = false

module.exports.setup = (server, auth_helper, rules) ->
	return

module.exports.get_token = (token, next) ->
	called = true
	data = {}

	# FIXME implement 

	return next(null, data)

