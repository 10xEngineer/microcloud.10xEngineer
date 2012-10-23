#
# Labs API 1.x uses hash-based message authentication code (HMAC) to validate the
# request caller identity.
#
# Digest: SHA256
# 
# TODO link to upstream identity server
# TODO add caching layer
#

restify = require("restify")
crypto = require("crypto")
mgmt_api = require("../api/mgmt/default")

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

	mgmt_api.getToken req.headers["x-labs-token"], (err, token) ->
		if err
			return next(new restify.InternalError("Unable to retrieve authentication token: #{err}"))

		hmac = crypto.createHmac('sha256', new Buffer(token["auth_secret"], 'base64'))
		hmac.update(req.method)

		hmac.update(req.headers.date)
		hmac.update(req.headers["x-labs-token"])
		hmac.update(req.headers.body) if req.headers.body

		expected_digest = hmac.digest('base64')

		if expected_digest != req.headers["x-labs-signature"]
			return next(new restify.InvalidCredentialsError("Invalid credentials"))

		next()

module.exports.setup = (server) ->
	server.use enforce_date
	server.use restify.dateParser(defaultSkew)
	server.use verifyHMAC

	# TODO upstream key request/local cache (TTL ~300 seconds)
	# Date: Date
	# X-Labs-token:
	# X-Labs-signature:	

	# TODO HMAC
