log = require("log4js").getLogger()
_   = require 'underscore'

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
  data = _.defaults JSON.parse(req.body), 
    method: 'log'
  if _.isFunction fn = res.everyone.now[data.method] then fn data
  res.send 200
