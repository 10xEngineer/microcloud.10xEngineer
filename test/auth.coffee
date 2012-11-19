request 		= require "supertest"
platform_api 	= require "../api/server"
auth 			= require "../utils/auth"

describe 'Authentication', () ->
	describe "Preconditions", () ->
		platform_api.setup()
		server = platform_api.run(auth, auth)

		it "should require HTTP Date Header", (done) ->
			exp_response = 
				code: "PreconditionFailed"
				message: "HTTP Date header missing"

			request(server)
				.get('/ping')
				.expect(412)
				.expect(JSON.stringify(exp_response))
				.end(done)

		it "shouldn't accept HTTP Date +/- 10 minutes range from current time", (done) ->
			minutes = 11
			time_diff = minutes * 60 * 1000
			date = new Date(new Date() - time_diff).toUTCString()

			exp_response = 
				code: "RequestExpired"
				message: "Date header is too old"

			request(server)
				.get('/ping')
				.set('Date', date)
				.expect(400)
				.expect(JSON.stringify(exp_response))
				.end(done)

		it "should require X-Labs-Token & X-Labs-Signature headers", (done) ->
			date = new Date().toUTCString()

			exp_response = 
				code: "PreconditionFailed"
				message: "Missing authentication headers (X-Labs-Token and/or X-Labs-Signature"

			request(server)
				.get('/ping')
				.set('Date', date)
				.expect(412)
				.expect(JSON.stringify(exp_response))
				.end(done)


	describe "HMAC", () ->
		platform_api.setup()
		server = platform_api.run(auth, auth)

		#it "should call get_token with X-Labs-Token header value", (done) ->
