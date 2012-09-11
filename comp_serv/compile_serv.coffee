log = require("log4js").getLogger()
nconf = require "nconf"
restify = require "restify"
mongoose = require "mongoose"
ssh_exec = require("./utils/ssh").ssh_exec

# sandboxes 
# - prepare
#   1. select node (based on sandbox type)
#   2. 
#
# - exec
# - destroy

server = restify.createServer
	name: "compile_service.10xengineer.me"
	version: "0.1.0"

server.use(restify.bodyParser())


server.post '/sandboxes', (req, res, next) ->
	# TODO validate data
	#      comp_kit
	#      source_url
	#      pub_key
	data = JSON.parse req.body

	comp_kit = data.comp_kit
	source_url = data.source_url
	pub_key = data.pub_key

	sandbox_id = null

	session = ssh_exec "mchammer@localhost", "sudo /opt/10xlabs/compile/bin/create #{comp_kit} \"#{source_url}\" \"#{pub_key}\""
	session.on 'data', (data) ->
		parts = data.toString().split("=")
		if parts[0] == "sandbox_id"
				sandbox_id = parts[1].replace(/^\s\s*$/, '').replace(/(\r\n|\n|\r)/gm,'')
		else
			log.warn "unexpected output: #{data.toString()}"

	session.on 'end', () ->
		res.send 201, sandbox_id

	session.on 'failed', (code) ->
		console.log 'failed', code
		res.send code, "failed"

server.post '/sandboxes/:sandbox/exec', (req, res, next) ->
	# TODO validate data
	#      cmd
	#      [optional] arg1
	#      [optional] arg2
	data = JSON.parse req.body

	sandbox = req.params.sandbox
	cmd = data.cmd

	exec_cmd = "sudo /opt/10xlabs/compile/bin/exec #{sandbox} #{cmd}"
	if data.arg1
		exec_cmd += " #{data.arg1}"
		if data.arg2
			exec_cmd += " #{data.arg2}"

	# TODO catch-22 as HTTP 200 is sent by default; the problem is the real 
	#      command status code is known only after the data has been received.
	res.writeHead(200, "Content-Type: text/plain")

	session = ssh_exec "mchammer@localhost", exec_cmd
	session.on 'data', (data) ->
		res.write data, 'ascii'

	session.on 'end', () ->
		res.end()

	session.on 'failed', () ->
		res.end()

server.del '/sandboxes/:sandbox', (req, res, next) ->
	sandbox = req.params.sandbox

	output = ""

	session = ssh_exec "mchammer@localhost", "sudo /opt/10xlabs/compile/bin/destroy #{sandbox}"
	session.on 'end', () ->
		res.send 200, "ok"

	session.on 'data', (data) ->
		output += data
		console.log data.toString()

	session.on 'failed', (code) ->
		code = 500 unless code?
		res.send code, "failed: #{output}"


server.listen 8001, () ->
	log.info "#{server.name} listening at port 8001"
