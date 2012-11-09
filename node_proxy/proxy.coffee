log 		= require("log4js").getLogger()
httpProxy 	= require("http-proxy")

proxyServer =  httpProxy.createServer (req, res, proxy) ->
	machine_uuid = req.headers.machine_uuid
	machine_ipv4 = req.headers.machine_ipv4
	machine_port = req.headers.machine_port

	buffer = httpProxy.buffer(req)

	proxy.proxyRequest req, res,
		host: machine_ipv4
		port: machine_port

proxyServer.listen 8000
