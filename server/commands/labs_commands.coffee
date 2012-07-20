module.exports = ->

log = require("log4js").getLogger()
mongoose = require("mongoose")
Lab = mongoose.model("Lab")
broker = require("../broker")
async     = require 'async'

module.exports.create = (req, res, next) ->
	# FIXME not yet finished
	# 
	# 1. get link to other lab definition
	# 2. generate name (if not provided)
	# 3. clone based on 10xlabs URL
	data = {}

	try 
		data = JSON.parse req.body if req.body
	catch error
		return res.send 406, 
			reason: "Invalid request data: #{error}"

	async.waterfall [
		(next) ->
			# create respository
			options = 
			    repo: data.repo

			broker.dispatch 'git_adm', "create_repo", options, (message) =>
				if message.status == 'ok'
					next null, message.options.repo, message.options.token
				else
					next 
						message: "Unable to create GIT repository: #{message.options.reason}"
						code: 500
		(repo, token, next) ->
			# save lab instance
			lab_data = 
				name: "test_lab"
				token: token
				repo: repo

			lab = new Lab(lab_data)
			lab.save (err) ->
				if err
					next 
						message: "Unable to save lab instance: #{err.message}"
						code: 500
				else next null, lab
	], (err, lab) ->
	    if err
	      	res.send 500, 
	        	reason: err.message
	    else
	    	log.info "lab=#{lab.name} created"
	   		res.send lab



