module.exports = ->

mongoose = require "mongoose"
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

	# pass notification to internal object
	model_name = null
	# TODO replace with underscore to camel case to get model name
	# TODO change Hostnode to Node
	switch resource
		when "vm" then model_name = 'Vm'
		when "lab" then model_name = 'Lab'
		when "node" then model_name = 'Hostnode'
		when "provider" then model_name = 'Provider'
		when "pool" then model_name = 'Provider'

	# resolve object
	try
		model = mongoose.model model_name
	catch error
		console.log error
		log.error "notification for invalid resource=#{resource}"
		return res.send 500, {reason: "Invalid resource type: '#{resource}'"}

	# TODO allow both internal and custom objects
	# TODO how to handle custom objects? are there any custom objects?
	#      will be relevant once we got custom components in place
	model
		.findOne({uuid: uuid})
		.exec (err, doc) ->
			if doc
				doc.fire data.event, data[resource]

				res.send 201, {status: "ok"}
			else
				log.error "Notification for invalid #{resource}=#{uuid}"
				res.send 404, {reason: "No resource found."}

	# don't need to publish now, it's facilitated via Schema.fire
	#client.publish "#{resource}:#{uuid}", JSON.stringify(notification)

	