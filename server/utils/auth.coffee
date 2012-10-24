#
# Labs API 1.x uses hash-based message authentication code (HMAC) to validate the
# request caller identity.
#
# Digest: SHA256
# 
# TODO link to upstream identity server
# TODO add caching layer
#

log 		= require("log4js").getLogger()
restify 	= require("restify")
crypto 		= require("crypto")
mgmt_api 	= require("../api/mgmt/client")

defaultSkew = 600

# enforce HTTP Date header to prevent clock-skew-related problems
enforce_date = (req, res, next) ->
	if (!req.headers.date)
		e = new restify.PreconditionFailedError("HTTP Date header missing")

		return next(e)

	date = new Date(req.headers.date).getTime();

	unless date
		return next(new restify.PreconditionFailedError("Invalid date specified"))

	return next()

verifyHMAC = (req, res, next) ->
	if (!req.headers["x-labs-token"] | !req.headers["x-labs-signature"])
		e = new restify.PreconditionFailedError("Missing authentication headers (X-Labs-Token and/or X-Labs-Signature")

		return next(e)

	# verify headers
	unless /^([a-z0-9]){28}$/.test(req.headers["x-labs-token"])
		return next(new restify.PreconditionFailedError("Invalid authentication token"))

	mgmt_api.tokens.show req.headers["x-labs-token"], (err, token) ->
		if err
			return next(new restify.InternalError("Unable to retrieve authentication token: #{err}"))

		hmac = crypto.createHmac('sha256', token["auth_secret"])
		hmac.update(req.method)
		hmac.update(req.url)
		hmac.update(req.headers.date)
		hmac.update(req.headers["x-labs-token"])
		#hmac.update(req.headers.body) if req.headers.body

		expected_digest = hmac.digest('base64')

		if expected_digest != req.headers["x-labs-signature"]
			return next(new restify.InvalidCredentialsError("Invalid credentials"))

		req.user = token.user

		next()

module.exports.setup = (server) ->
	server.use enforce_date
	server.use restify.dateParser(defaultSkew)
	server.use verifyHMAC

module.exports.verify = (account_handle, callback) ->
	return (req, res, next) ->
		mgmt_api.accounts.show account_handle, (err, account) ->
			if err
				return (req, res, next) ->
					next(new restify.InternalError("Unable to retrieve account '#{account_handle}': #{err}"))

			unless account
				return (req, res, next) ->
					next(new restify.InternalError("Account '#{account_handle}' missing"))

			# Simple RBAC based on account ownership
			if req.user.id in account.owners
				return callback(req, res, next)

			log.warn("user=#{req.user.id} access denied to url=#{req.url}")

			return next(new restify.ForbiddenError("Forbidden"))
