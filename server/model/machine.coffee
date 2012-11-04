log 		= require("log4js").getLogger()
mongoose 	= require "mongoose"
Schema		= mongoose.Schema
ObjectId 	= Schema.ObjectId;
async 		= require "async"

ProxyUser 	= mongoose.model 'ProxyUser'

timestamps 	= require "../utility/timestamp_plugin"

SSHProxy = new Schema 
	proxy_user: String
	fingerprint: String
	public_key: String

	user: String

Machine = new Schema
	uuid: String
	name: String

	account: ObjectId
	node: {
		node_id: ObjectId
		hostname: String
	}
	lab: ObjectId

	state: String
	template: String

	ssh_proxy: [SSHProxy]

	ipv4_address: String

	# TODO statistics - update periodically
	snapshots_count: Number
	total_storage: Number

	archived: {type: Boolean, default: false}

Machine.plugin(timestamps)
Machine.index({name: 1, account: 1, archived:1}, {unique: true})

Machine.statics.getCurrentUsage = (user, callback) ->
	mongoose.model('Machine')
		.find({account: user.account_id, archived: false, deleted_at: null})
		.exec (err, machines) ->
			if err
				# TODO return error
				return callback(-1)

			return callback(null, machines.length)

Machine.statics.create_proxy = (key, user, callback) ->
	getProxyUser = (callback, results) ->
		ProxyUser
			.find({disabled: false})
			.where("deleted_at").equals(null)
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
			fingerprint: key.fingerprint
			public_key: key.public_key
			user: user.id

		return callback(null, proxy_data)

	async.auto
		proxy_user: getProxyUser
		ssh_proxy: ['proxy_user', createProxy]
	, (err, results) ->
		if err 
			return callback(err)

		return callback(null, results.ssh_proxy)

module.exports.register = mongoose.model 'Machine', Machine