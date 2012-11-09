log 		= require("log4js").getLogger()
restify 	= require("restify")
config 		= require("./gateway_proxy/config")
httpProxy 	= require("http-proxy")
api_client 	= require("./server/api/platform/client")
lru			= require("lru-cache")

proxy_serv 	= config.get('service')
region 		= config.get('microcloud:name')
node_port	= config.get('node:port')

options 	=
	max: config.get("cache:max")
	maxAge: config.get("cache:maxAge")

# TODO LRU cache timeout works for inactive entries only, need to figure out to how evict entries
#      no matter if they are used or not
cache 		= lru(options)

api_client.setup(
	config.get('microcloud:token'), 
	config.get('microcloud:secret'),
	config.get('microcloud:url'))

proxyError = (code, message, req, res) ->
	res.writeHead(code, { 'Content-Type': 'text/plain' })
	res.write(message)
	return res.end()

getMachine = (token, callback) ->
	# try cache first
	machine = cache.get(token)

	return callback(null, machine) if machine

	# fallback to API
	log.debug "token=#{token} missed cache"
	api_client.get "/machines/token/#{token}", (err, machine_req, machine_res, machine) ->
		return callback(err, machine)

proxyServer =  httpProxy.createServer (req, res, proxy) ->
	host_re = /^([a-e0-9]+)\.([\w-]+)\.10xlabs\.(net|dev)(\:(\d+)){0,1}$/
	host_match = host_re.exec(req.headers.host)

	unless host_match 
		res.writeHead(400, { 'Content-Type': 'text/plain' })
		res.write('Invalid request')
		return res.end()

	unless host_match[2] == region
		res.writeHead(412, { 'Content-Type': 'text/plain' })
		res.write("Wrong microcloud destination: #{host_match[2]}")
		return res.end()

	token = host_match[1]
	buffer = httpProxy.buffer(req)

	# TODO add cache layer to limit number of mongo requests
	#api_client.get "/machines/token/#{token}", (err, machine_req, machine_res, machine) ->
	getMachine token, (err, machine) ->
		if err
			# 404 is not really an error
			unless err.statusCode == 404
				log.error "Unable to retrieve machine for token=#{token}"

				return proxyError(500, "Internal server error: #{err}", req, res)
			else
				machine = null

		unless machine
			log.error "No machine for token=#{token}"

			return proxyError(410, "Target Lab Machine is gone", req, res)

		# save to cache
		cache.set(token, machine)

		mapping = machine.port_mapping || {}
		unless mapping.http
			return proxyError(406, "No '#{proxy_serv}' forwarding configured for machine '#{machine.name}'", req, res)

		hostnode = machine.node.hostname

		req.headers["machine_uuid"] = machine.uuid
		req.headers["machine_ipv4"] = machine.ipv4_address
		req.headers["machine_port"] = machine.port_mapping.http

		# TODO remove
		console.log hostnode
		console.log req.headers

		# TODO proxy to hostnode (instead of localhost)
		proxy.proxyRequest req, res,
			host: hostnode
			port: node_port
			buffer: buffer

proxyServer.listen config.get('port')
