log 			= require("log4js").getLogger()
platform_api	= require("../api/platform")

module.exports.get_token = (token, callback) ->
	platform_api.tokens.show token, callback

module.exports.get_account = (account_handle, callback) ->
	platform_api.accounts.show account_handle, callback