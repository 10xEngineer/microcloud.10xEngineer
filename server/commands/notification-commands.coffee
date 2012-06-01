module.exports = ->

subscriptions = []

module.exports.subscribe = (userid) ->
	if userid.length && subscriptions.indexOf(userid) == -1
		subscriptions.push userid

module.exports.unsubscribe = (userid) ->
	if userid.length && subscriptions.indexOf(userid) != -1
		subscriptions.pop userid
