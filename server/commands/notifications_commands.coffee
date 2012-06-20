module.exports = ->

log = require("log4js").getLogger()
mongoose = require("mongoose")
Provider = mongoose.model('Provider')
Hostnode = mongoose.model('Hostnode')

subscriptions = []

module.exports.subscribe = (userid) ->
	if userid.length && subscriptions.indexOf(userid) == -1
		subscriptions.push userid

module.exports.unsubscribe = (userid) ->
	if userid.length && subscriptions.indexOf(userid) != -1
		subscriptions.pop userid

# TODO move to appropriate module (servers)
module.exports.dummy = (req, res, next) ->
  data = JSON.parse(req.body)
  # FIXME verify data/action
  Hostnode.find_by_server_id req.params.server, (err, hostnode) ->
    if hostnode
      # FIXME process body to find action
      hostnode.fire data["action"], data.hostnode , (err) -> 
        if err
          console.log(err)

      res.send 200
    else
      log.error("Notification for invalid hostnode=#{req.params.server}")
      res.send 404, {}
