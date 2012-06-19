module.exports = ->

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

module.exports.dummy = (req, res, next) ->
  data = JSON.parse(req.body)
  # FIXME verify data/action
  Hostnode.find_by_server_id req.params.server, (err, hostnode) ->
    if hostnode
      # FIXME process body to find action
      hostnode.fire data["action"], {}, (err) -> 
        if err
          console.log(err)

      res.send 200
    else
      res.send 404, "Hostnode not found"
