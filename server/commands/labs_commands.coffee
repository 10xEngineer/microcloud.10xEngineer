module.exports = ->

log = require("log4js").getLogger()
mongoose = require("mongoose")
Lab = mongoose.model("Lab")
Vm = mongoose.model("Vm")
Definition = mongoose.model("Definition")
Pool = mongoose.model("Pool")
broker = require("../broker")
async     = require 'async'
crypto    = require 'crypto'
BasicDefinition = require "../labs/basic_definition"
fs = require "fs"

# TODO release
#      - run down migration (not part of the command itself - async)
#      - run up migration (not part of the command itself - async)
# TODO keep history in files (include version information in filename)

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

	unless data.pools
		return res.send 412
			reason: "Resource pools not provided."

	unless data.attrs?
		log.warn "no attributes submitted for lab=#{data.name}"
		
	lab_attrs = data.attrs || {}

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
				attrs: lab_attrs

			lab = new Lab(lab_data)
			lab.markModified('attrs')
			lab.save (err) ->
				if err
					log.warn "Failed to save lab instance; reason=#{err.message}"
					next 
						message: "Unable to save lab instance: #{err.message}"
						code: 500
				else next null, lab
		(lab, next) ->
			# references to resource pools
			resolve_pool = (pool_type, cb) ->
				pool_name = data.pools[pool_type]

				unless pool_name?
					return cb(null)

				Pool
					.findOne({name: pool_name})
					.exec (err, pool)  ->
						unless err
							lab.pools[pool_type] = pool._id
							return cb()
						else
							return cb(err)

			async.forEach ["compute", "storage", "network"], resolve_pool, (err) ->
				# TODO validate if required pools are provided
				next null, lab

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
			lab.markModified("pools")
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
	   		res.send 201, lab


module.exports.show = (req, res, next) ->
	Lab
		.findOne({name: req.params.lab})
		.populate("current_definition")
		.exec (err, lab) ->
			unless lab
				return res.send 404, 
					reason: "Lab not found."

			res.send lab

module.exports.archive = (req, res, next) ->
	# TODO set proper headers
	# TODO file download doesn't have any size indication
	serve_file = (filename, callback) ->
		_file = filename.split('/')[-1..]
		fs.exists filename, (exists) ->
			unless exists
				return callback(new Error("Archive missing"))

			stats = fs.stat filename, (err, stats) ->
				if err
					return callback(new Error("Unable to stat archive."))

				res.contentType = "application/gzip"
				res.header "Content-Disposition", "attachment; filename=#{_file}"
				res.header "Content-Length", stats.size

				stream = fs.createReadStream(filename)
				return stream.pipe(res)

	Lab
		.findOne({name: req.params.lab})
		.populate("current_definition")
		.exec (err, lab) ->
			unless lab
				return res.send 404, 
					reason: "Lab not found."

			# FIXME lab definition should have commit to link the particular revision and version
			commit = 'master'

			options = 
				repo: lab.repo
				commit: commit

			req = broker.dispatch 'git_adm', "archive_to_file", options
			req.on 'data', (message) =>
				archive = message.options.archive

				serve_file archive, (err) ->
					if err
						res.send err.message

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
				.select("uuid vm_name state descriptor")
				.exec (err, vms) ->
					res.send vms

module.exports.get_vm = (req, res, next) ->
	Lab
		.findOne({name: req.params.lab})
		.populate("current_definition")
		.exec (err, lab) ->
			unless lab
				return res.send 404, 
					reason: "Lab not found."

			vms = lab.operational.vms
			for vm in vms
				if vm.name == req.params.vm
					Vm
						.findOne({_id: vm.vm})
						.select("uuid vm_name state descriptor")
						.exec (err, lab_vm) ->
							return res.send lab_vm if lab_vm?

			res.send 404, "Unknown vm=#{req.params.vm} for lab=#{req.params.lab}"

module.exports.show_versions = (req, res, next) ->
	versions = []
	Lab
		.findOne({name: req.params.lab})
		.exec (err, lab) ->
			if err
				return res.send 500,
					reason: "Unable to get lab '#{req.params.lab}': #{err}"

			if lab
				Definition
					.find({lab: lab})
					.select('version revision meta')
					.exec (err, defs) ->
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
				.populate("pools.compute")
				.populate("pools.network")
				.populate("pools.storage")
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

module.exports.destroy = (req, res, next) ->
	processor_type = BasicDefinition

	Lab
		.findOne({name: req.params.lab})
		.populate("current_definition")
		.exec (err, lab) ->
			unless lab
				return res.send 404, 
					reason: "Lab not found."

			processor = new processor_type(lab, null)
			processor.on "accepted", (msg) ->
				res.send 202,
					message: msg

			processor.on "refused", (msg) ->
				res.send 406,
					message: msg

			processor.destroy()
			