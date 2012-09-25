module.exports = ->

log = require("log4js").getLogger()
ssh_exec = require("../utility/ssh").ssh_exec
config = require("nconf")

compile_node = (key = 'compilation') ->
	return config.get(config.get('NODE_ENV')+':'+key)

module.exports.index = (req, res, next) ->
	res.send 500, "NOT IMPLEMENTED"

module.exports.create = (req, res, next) ->
	# TODO validate data
	#      comp_kit
	#      source_url
	#      pub_key
	data = JSON.parse req.body

	comp_kit = data.comp_kit
	source_url = data.source_url
	pub_key = data.pub_key

	sandbox_id = null

	session = ssh_exec compile_node(), "sudo /opt/10xlabs/compile/bin/create #{comp_kit} \"#{source_url}\" \"#{pub_key}\""
	session.on 'data', (data) ->
		parts = data.toString().split("=")
		if parts[0] == "sandbox_id"
				sandbox_id = parts[1].replace(/^\s\s*$/, '').replace(/(\r\n|\n|\r)/gm,'')
		else
			log.warn "unexpected output: #{data.toString()}"

	session.on 'end', () ->
		res.send 201, 
			sandbox: sandbox_id

	session.on 'failed', (code) ->
		console.log 'failed', code
		res.send code, "failed"

module.exports.execute = (req, res, next) ->
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

	session = ssh_exec compile_node(), exec_cmd
	session.on 'data', (data) ->
		res.write data, 'ascii'

	session.on 'end', () ->
		res.end()

	session.on 'failed', () ->
		res.end()	

module.exports.destroy = (req, res, next) ->
	sandbox = req.params.sandbox

	output = ""

	session = ssh_exec compile_node(), "sudo /opt/10xlabs/compile/bin/destroy #{sandbox}"
	session.on 'end', () ->
		res.send 200, "ok"

	session.on 'data', (data) ->
		output += data
		console.log data.toString()

	session.on 'failed', (code) ->
		code = 500 unless code?
		res.send code, "failed: #{output}"

