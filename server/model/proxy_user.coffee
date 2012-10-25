log 		= require("log4js").getLogger()
mongoose 	= require 'mongoose'
Schema 		= mongoose.Schema
ObjectId 	= Schema.ObjectId

ProxyUser = new Schema {
	name: String
	disabled: {type: Boolean, default: false}
}, {
	collection: 'proxy_users'
}

ProxyUser.plugin(timestamps)

module.exports.register = mongoose.model 'ProxyUser', ProxyUser