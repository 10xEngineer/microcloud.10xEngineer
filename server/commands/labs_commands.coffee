module.exports = ->

log = require("log4js").getLogger()
mongoose = require("mongoose")
Lab = mongoose.model("Lab")
broker = require("../broker")
async     = require 'async'
crypto    = require 'crypto'

module.exports.create = (req, res, next) ->
	# FIXME not yet finished
	# FIXME integrate owner/domain/user
	# 
	# 1. get link to other lab definition
	# 3. clone based on 10xlabs URL (currently only git repo)
	data = {}

	try 
		data = JSON.parse req.body if req.body
	catch error
		return res.send 406, 
			reason: "Invalid request data: #{error}"

	unless data.name
		return res.send 412
			reason: "Lab 'name' is required."

	async.waterfall [
		(next) ->
			# TODO process parent lab/repo
			# https://trello.com/card/clone-from-lab/50067c2712a969ae032917f4/24
			if data.parent_lab
				next
					message: "Cloning from lab is not (yet) supported, sorry."
					code: 501
			else next null
		(next) ->
		    # generate token
			crypto.randomBytes 32, (ex,buf) ->
				# TODO url safe base64 encoding
				token = buf.toString('base64')
				next null, token
		(token, next) ->
			# create lab object before repository/compilation service kicks in
			# to prevent any sort of race condition (highly unlikely)
			# TODO consider setting lab temporary status (need further analysis)
			lab_data = 
				name: data.name
				token: token

			lab = new Lab(lab_data)
			lab.save (err) ->
				if err
					next 
						message: "Unable to save lab instance: #{err.message}"
						code: 500
				else next null, lab
		(lab, next) ->
			# create respository
			options = 
			    repo: data.repo
			    token: lab.token
			    # TODO extend as part of owner/user inclusing (see above)
			    lab_name: data.name

			broker.dispatch 'git_adm', "create_repo", options, (message) =>
				if message.status == 'ok'
					next null, lab, message.options.repo
				else
					next 
						message: "Unable to create GIT repository: #{message.options.reason}"
						code: 500
		(lab, repo, next) ->
			# update lab definition
			lab.repo = repo
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


module.exports.show = (req, res, next) ->
	console.log '--> lab get'
	console.log req.params

	res.send {}

