log = require("log4js").getLogger()

module.exports.subscribe = (userid) ->
	if userid.length && subscriptions.indexOf(userid) == -1
		subscriptions.push userid

module.exports.unsubscribe = (userid) ->
  if userid.length && subscriptions.indexOf(userid) != -1
    subscriptions.pop userid

# Send notification to clients connected via NowJS
# 
# res.everyone is initialized object, which is added in 
# restify middleware (/microcloud.coffee)
module.exports.send = (req, res, next) ->
  notification = JSON.parse req.body
  res.everyone.now.log notification
  res.send 200
