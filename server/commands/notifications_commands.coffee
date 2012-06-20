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


