log 		= require("log4js").getLogger()
restify 	= require("restify")
#config 		= require("./gateway_proxy/config")
httpProxy 	= require("http-proxy")
api_client 	= require("./server/api/platform/client")

# TODO configurable region name (^^)
microcloud_region = "eu-1-aws"

# TODO configurable
api_client.setup(
	"af124df24862fb214a7385c37acd", 
	"73dbede5a8cbef14cfd67892a4ad039bb71c6b82b83e9f32",
	"http://api.labs.internal/")

proxyServer =  httpProxy.createServer (req, res, proxy) ->
	host_re = /^([a-e0-9]+)\.([\w-]+)\.10xlabs\.(net|dev)(\:(\d+)){0,1}$/
	host_match = host_re.exec(req.headers.host)

	unless host_match 
		res.writeHead(400, { 'Content-Type': 'text/plain' })
		res.write('Invalid request')
		return res.end()

	unless host_match[2] == microcloud_region
		res.writeHead(412, { 'Content-Type': 'text/plain' })
		res.write("Wrong microcloud destination: #{host_match[2]}")
		return res.end()

	token = host_match[1]
	buffer = httpProxy.buffer(req)

	# TODO add cache layer to limit number of mongo requests
	api_client.get "/machines/token/#{token}", (err, machine_req, machine_res, machine) ->
		if err
			# 404 is not really an error
			unless err.statusCode == 404
				log.error "Unable to retrieve hostnode for token=#{token}"

				res.writeHead(500, { 'Content-Type': 'text/plain' })
				res.write("Internal server error: #{err}")
				return res.end()
			else
				machine = null

		unless machine
			log.error "Unable to retrieve hostnode for token=#{token}"

			res.writeHead(410, { 'Content-Type': 'text/plain' })
			res.write("Target Lab Machine is gone")
			return res.end()

		hostnode = machine.node.hostname

		req.headers["machine_uuid"] = machine.uuid
		req.headers["machine_ipv4"] = machine.ipv4_address
		req.headers["machine_port"] = 3000

		# TODO proxy to hostnode (instead of localhost)
		proxy.proxyRequest req, res,
			host: hostnode
			port: 8000
			buffer: buffer

proxyServer.listen 80
