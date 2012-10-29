module.exports = ->

log 		= require('log4js').getLogger()
restify		= require 'restify'
crypto 		= require 'crypto'

version = "v1"

PLATFORM_API_CONFIG = {}

setup_auth = (method, url, body) ->
		date = new Date().toUTCString()

		hmac = crypto.createHmac('sha256', PLATFORM_API_CONFIG.secret)
		hmac.update(method)
		hmac.update(url)
		hmac.update(date)
		hmac.update(PLATFORM_API_CONFIG.token)
		hmac.update(body) if body

		digest = hmac.digest('base64')

		headers = 
			"Date": date
			"X-Labs-Token": PLATFORM_API_CONFIG.token
			"X-Labs-Signature": digest

		return headers

create_client = (method, url, body = null) ->
	return restify.createJsonClient
			url: PLATFORM_API_CONFIG.endpoint
			headers: setup_auth(method, url, body)

module.exports.setup = (token, secret, endpoint) ->
	PLATFORM_API_CONFIG = 
		token: token
		secret: secret
		endpoint: endpoint

module.exports.get = (url, callback) ->
	client = create_client('GET', url)

	_url = "/" + version + url

	client.get _url, callback
