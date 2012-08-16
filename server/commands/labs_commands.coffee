module.exports = ->

log = require("log4js").getLogger()
mongoose = require("mongoose")
Lab = mongoose.model("Lab")
Vm = mongoose.model("Vm")
Definition = mongoose.model("Definition")
broker = require("../broker")
async     = require 'async'
crypto    = require 'crypto'
BasicDefinition = require "../labs/basic_definition"

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

			req = broker.dispatch 'git_adm', "create_repo", options
			req.on 'data', (message) =>
				next null, lab, message.options.repo
			
			req.on 'error', (message) ->
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
	Lab
		.findOne({name: req.params.lab})
		.populate("current_definition")
		.exec (err, lab) ->
			unless lab
				return res.send 404, 
					reason: "Lab not found."

			res.send lab

module.exports.get_vms = (req, res, next) ->
	Lab
		.findOne({name: req.params.lab})
		.populate("current_definition")
		.exec (err, lab) ->
			unless lab
				return res.send 404, 
					reason: "Lab not found."

			Vm
				.find({lab: lab._id})
				.exec (err, vms) ->
					res.send vms


module.exports.show_versions = (req, res, next) ->
	versions = []
	Lab
		.findOne({name: req.params.lab})
		.exec (err, lab) ->
			if err
				return res.send 500,
					reason: "Unable to get lab '#{req.params.lab}': #{err}"

			if lab
				Definition.find {lab: lab}, ['version', 'revision', 'meta'], (err, defs) ->
					if err
						return res.send 500,
							reason: "Unable to get definitions versions: #{err}"

					return res.send defs

module.exports.submit_version = (req, res, next) ->
	unless req.body
		return res.send 412, 
			reason: "Missing request body."
	
	try 
		data = JSON.parse req.body if req.body
	catch error
		return res.send 406, 
			reason: "Invalid request data: #{error}"

	# FIXME hardcoded definition processing class (should be configurable
	#       possibly with lab itself/10xlab installation)
	processor_type = BasicDefinition
	
	Lab
		.findOne({name: req.params.lab})
		.populate("current_definition")
		.exec (err, lab) ->
			if err
				return res.send 500,
					reason: "Unable to get lab: #{err}"

			if lab
				processor = new processor_type(lab, data)

				processor.on "accepted", () ->
					res.send 201

				processor.on "refused", (message) ->
					log.debug "definition for lab=#{lab.name} refused"
					res.send 303, 
						reason: message

				processor.validate()
			else
				log.debug "invalid lab"
				return res.send 404,
					reason: "Lab not found."		

module.exports.release_version = (req, res, next) ->
	# TODO parse req.body - reserved for authorization and other meta information related 
	#      release workflow
	metadata = {}

	# FIXME hardcoded definition processing class (should be configurable
	#       possibly with lab itself/10xlab installation)
	processor_type = BasicDefinition

	async.waterfall [
		(next) ->
			# get lab
			Lab
				.findOne({name: req.params.lab})
				.populate("current_definition")
				.exec (err, lab) ->
					if err
						return next 
							code: 500
							reason: "Unable to get lab: #{err}"

					if lab
						next null, lab
					else next 
						code: 404
						reason: "Lab '#{req.params.lab}' not found."
		(lab, next) ->
			# find request lab definition version
			Definition
				.findOne({lab: lab, version: req.params.version})
				.exec (err, lab_def) ->
					if err
						return next 
							code: 500
							reason: "Unable to get lab definition version: #{err}"

					if lab_def
						next null, lab, lab_def
					else
						next
							code: 404
							reason: "Lab definition with version '#{req.params.version}' not found"
	], (err, lab, definition) ->
		if err
			res.send err.code, { reason: err.reason }
		else
			processor = new processor_type(lab, definition)
			processor.on "accepted", () ->
				res.send 202,
					message: "Request to release version '#{definition.version}' successfully accepted."
			processor.on "refused", (message) ->
				res.send 406, 
				reason: message

			processor.release(metadata)

	# TODO release
	#      - run down migration (not part of the command itself - async)
	#      - run up migration (not part of the command itself - async)
	# TODO keep history in files (include version information in filename)
