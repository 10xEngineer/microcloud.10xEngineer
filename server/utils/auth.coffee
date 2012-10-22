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

defaultSkew = 600

enforce_date = (req, res, next) ->
	if (!req.headers.date)
		e = new restify.PreconditionFailedError("HTTP Date header missing")

		return next(e)

	return next()

verifyHMAC = (req, res, next) ->
	if (!req.headers["x-labs-token"] | !req.headers["x-labs-signature"])
		e = new restify.PreconditionFailedError("Missing authentication headers (X-Labs-Token and/or X-Labs-Signature")

		return next(e)

	# FIXME lookup
	secret = 'dummy123'

	hmac = crypto.createHmac('sha256', secret)
	hmac.update(req.headers.date)
	hmac.update(req.headers["x-labs-token"])
	hmac.update(req.headers.body)

	expected_digest = hmac.digest('base64')

	if expected_digest != req.headers["x-labs-signature"]
		return next(new restify.InvalidCredentials("Invalid credentials"))

	return next()

module.exports.setup = (server) ->
	# enforce HTTP Date header to prevent clock-skew-related problems
	server.use enforce_date
	server.use restify.dateParser(defaultSkew)
	server.use verifyHMAC

	# TODO upstream key request/local cache (TTL ~300 seconds)
	# Date: Date
	# X-Labs-token:
	# X-Labs-signature:	

	# TODO HMAC
