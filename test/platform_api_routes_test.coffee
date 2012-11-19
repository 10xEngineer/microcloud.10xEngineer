request 		= require "supertest"
platform_api 	= require "../api/server"
auth 			= require "./support/fake_auth"

describe 'Routes', () ->
	describe "Status", () ->
		platform_api.setup()
		server = platform_api.run(auth)

		it "should respond to GET /ping", (done) ->
			response =
				status: "ok"

			request(server)
				.get('/ping')
				.expect(200)
				.expect(JSON.stringify(response))
				.end(done)