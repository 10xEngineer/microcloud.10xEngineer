log 		= require("log4js").getLogger()
mongoose 	= require 'mongoose'
async 		= require 'async'
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId
ProxyUser 	= mongoose.model "ProxyUser"

timestamps = require "../utility/timestamp_plugin"

ProxiedMachine = new Schema

SSHProxy = new Schema {
	proxy_user: String
	key: String

	user: String
	account: String
}, {
	collection: 'ssh_proxies'
}

SSHProxy.plugin(timestamps)

SSHProxy.statics.create_proxy = (key, user, callback) ->
	getProxyUser = (callback, results) ->
		ProxyUser
			.find({disabled: false})
			.where("meta.deleted_at").equals(null)
			.exec (err, proxy_users) ->
				if err
					return callback(new Error("Unable to retrieve proxy users: #{err}"))

				if proxy_users.length == 0
					return callback(new Error("No available proxy user"))

				proxy_user = proxy_users[Math.floor(Math.random()*proxy_users.length)]

				return callback(null, proxy_user)

	createProxy = (callback, results) ->
		proxy_data = 
			proxy_user: results.proxy_user.name
			key: key.public_key

			user: user.id
			account: user.account_id

		X = mongoose.model('SSHProxy')
		ssh_proxy = new X(proxy_data)
		ssh_proxy.save (err) ->
			if err
				return callback(new Error("Unable to save SSH Proxy: #{err}"))

			return callback(null, ssh_proxy)

	async.auto
		proxy_user: getProxyUser
		ssh_proxy: ['proxy_user', createProxy]
	, (err, results) ->
		if err 
			return callback(err)

		return callback(null, results.ssh_proxy)

module.exports.register = mongoose.model 'SSHProxy', SSHProxy