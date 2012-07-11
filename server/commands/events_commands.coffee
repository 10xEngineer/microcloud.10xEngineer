module.exports = ->

log = require("log4js").getLogger()


# FIXME migrate hostnode/vm notifications to event model
#		pro
#			+ use one event scheme (keep it concise)
#		cons
#			- some events are native to microcloud (where as other are lab specific)

# FIXME empty shell
dummy_resolve_id = (object_id, callback) ->
	# TODO return object definition (object class/type, associated lab)
	callback "node"

#
# 10xLabs event interface
#
module.exports.accept = (req, res, next) ->
	# FIXME not implemented
	# - accept as fast as possible
	#	options?:
	#		1. store in redis
	#		2. try to process / if crashes have periodic process to recover it
	#       or
	#		3. just try the best to process it (for now)
	# - resolve object_id
	# - push to the right 'processor/worker' based on object type
	#	Different types of workers 
	#		1. find subscribers
	#		2. match task/workflow
	#		3. 

	data = JSON.parse req.body
	dummy_resolve_id req.params.object_id, (object_type) ->
    console.log "--- object resolved: #{object}"

		# TODO hostnode -> bind to Hostnode.fire
		# TODO vm -> bind to Vm.fire (will issue updated notification's itself)
		# TODO custom vm notifications - TBD

		res.send {}