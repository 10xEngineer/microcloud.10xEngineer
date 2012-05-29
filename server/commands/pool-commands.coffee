module.exports = ->

module.exports.status = (req, res, next) ->
	res.send "pool_status NOT IMPLEMENTED"

module.exports.startup = (req, res, next) ->
	res.send "pool_startup NOT IMPLEMENTED"

module.exports.shutdown = (req, res, next) ->
	res.send "pool_shutdown NOT IMPLEMENTED"

module.exports.addserver = (req, res, next) ->
	res.send "pool_addserver NOT IMPLEMENTED"

module.exports.removeserver = (req, res, next) ->
	res.send "pool_removeserver NOT IMPLEMENTED"

module.exports.allocate = (req, res, next) ->
	res.send "pool_allocate NOT IMPLEMENTED"

module.exports.deallocate = (req, res, next) ->
	res.send "pool_deallocate NOT IMPLEMENTED"
