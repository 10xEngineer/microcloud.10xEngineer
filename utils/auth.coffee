#
# Labs API 1.x uses hash-based message authentication code (HMAC) to validate the
# request caller identity.
#
# Digest: SHA256
# 
# TODO add caching layer
#

log 			= require("log4js").getLogger()
restify 		= require("restify")
crypto 			= require("crypto")

defaultSkew = 600

module.exports.setup = (server, auth_helper, rules) ->
	verifyHMAC = (req, res, next) ->
		# bypass authentication based on specific rules
		for rule_name of rules
			rule = rules[rule_name]

			match = req.url.match rule.url_match
			if match
				if rule.schema == "none"
					log.info "path=#{req.path} bypassed by custom rule=#{rule_name} schema=none ip=#{req.connection.remoteAddress}"
					return next()
					
				if rule.schema == "token" && rule.token == match[1]
					log.info "path=#{req.path} bypassed by custom rule=#{rule_name} schema=token ip=#{req.connection.remoteAddress}"
					return next()

				return next(new restify.InvalidCredentialsError("Invalid credentials (special rules)"))

		# enforce Date header
		if (!req.headers.date)
			e = new restify.PreconditionFailedError("HTTP Date header missing")

			return next(e)

		date = new Date(req.headers.date).getTime();

		unless date
			return next(new restify.PreconditionFailedError("Invalid date specified"))


		if (!req.headers["x-labs-token"] | !req.headers["x-labs-signature"])
			e = new restify.PreconditionFailedError("Missing authentication headers (X-Labs-Token and/or X-Labs-Signature")

			return next(e)

		# verify headers
		unless /^([a-z0-9]){28}$/.test(req.headers["x-labs-token"])
			return next(new restify.PreconditionFailedError("Invalid authentication token"))

		auth_helper.get_token req.headers["x-labs-token"], (err, token) ->
			if err
				# NotFoundError/404 is not really an error
				if err.statusCode == 404
					return next(new restify.UnauthorizedError("Invalid credentials (token)"))

				return next(new restify.InternalError("Unable to retrieve authentication token: #{err}"))

			hmac = crypto.createHmac('sha256', token["auth_secret"])
			hmac.update(req.method)
			hmac.update(req.url)
			hmac.update(req.headers.date)
			hmac.update(req.headers["x-labs-token"])
			hmac.update(req.body) if req.body

			expected_digest = hmac.digest('base64')

			if expected_digest != req.headers["x-labs-signature"]
				return next(new restify.UnauthorizedError("Invalid credentials"))

			req.user = token.user

			unless req.user
				return next(new restify.UnauthorizedError("Principal missing"))

			next()	

	server.use restify.dateParser(defaultSkew)
	server.use verifyHMAC

module.exports.verify = (account_handle, auth_helper, callback) ->
	return (req, res, next) ->
		auth_helper.get_account account_handle, (err, account) ->
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
