log 		= require("log4js").getLogger()
mongoose 	= require "mongoose"
timestamps 	= require "../../server/utility/timestamp_plugin"
ObjectId 	= mongoose.Schema.ObjectId

# TODO generate account_ref
# TODO how to associate
#
# * user can log-in
# * account is where the accounting happens
#
# Use-cases:
# 1) account VM -> owner -> account_ref/group
# 2) create new VM, goes towards main account
# 3) 10xengineer organization -> needs roles
# 4) get list of all users under the account

Account = new mongoose.Schema
	handle: String

	# dropped account_ref in favor of _id
	#account_ref: String

	owners: [ObjectId]

	disabled: {type: Boolean, default: false}
	organization: {type: Boolean, default: false}

Account.plugin(timestamps)