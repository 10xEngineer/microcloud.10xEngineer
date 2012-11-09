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

proxyServer.proxy.on 'proxyError', (err, req, res) ->
	res.writeHead(500, { 'Content-Type': 'text/plain' })

	switch err.code
		when "ECONNREFUSED" then message = "Service not available. Are you it's running?"
		when "ECONNRESET" then message = "Service doesn't respond"
		else message = "Unable to connect to target Lab Machine!"

	res.write(message)
	res.end()

proxyServer.listen 8000
