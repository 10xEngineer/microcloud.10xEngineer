module.exports = ->

log = require("log4js").getLogger()
# TODO configurable/wrapped redis client
redis = require "redis"
client = redis.createClient()

#
# 10xLabs event interface
#
# {
#   "resource": "node",
#   "uuid": "XYZ"
#   "event": "event_name",
#   "node": {}
# }
#
# FIXME accept external notification for internal objects (somehow lookup mongoose models,
#       and fire appropriate notifications)
module.exports.accept = (req, res, next) ->
	data = JSON.parse req.body
	# FIXME validate 'resource', 'event', 'uuid' and optional resource key

	resource = data.resource
	uuid = data.uuid

	notification = 
		event: data.event

	notification[resource] = data[resource]

	log.trace "notification for resource=#{resource} event=#{data.event}"

	client.publish "#{resource}:#{uuid}", JSON.stringify(notification)

	res.send 201, {status: "ok"}