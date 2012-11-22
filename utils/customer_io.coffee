log 			= require("log4js").getLogger()
https 			= require("https")
config 			= require("nconf")

env = config.get('NODE_ENV')

client = null

get_user_id = (user) ->
	return "#{config.get('NODE_ENV')}_#{user.id}"

format_data = (data, opts) ->
	out = data

	for key of opts
		out += "&"
		out += "data[#{key}]="
		out += opts[key]

	return out

class CustomerIO
	constructor: (site_id, secret_key) ->
		@site_id = site_id
		@secret_key = secret_key

	send_event: (user, event_name, attributes = {}) ->
		return if env == "development"
		
		path = "/api/v1/customers/#{get_user_id(user)}/events"
		# &data[price]=11
		data = "name=#{event_name}"

		return if user.service

		out = format_data(data, attributes)

		post_options =
			host: "app.customer.io"
			path: path
			method: "POST"
			auth: "#{@site_id}:#{@secret_key}"
			headers:
				'Content-Type': 'application/x-www-form-urlencoded'
				'Content-Length': out.length

		post_req = https.request post_options, (res) ->
			unless res.statusCode == 200 			
				console.log "unable to submit data to customer.io code=#{res.statusCode}"
			res.on 'data', (chunk) ->

		post_req.write(out)
		post_req.end()

module.exports.setupClient = (site_id, secret_key) ->
	client =  new CustomerIO(site_id, secret_key)

	return client

module.exports.getClient = () ->
	raise "CustomerIO client not configured" unless client 

	return client
