module.exports = ->

mongoose = require "mongoose"
Definition = mongoose.model "Definition"
compare_versions = require('./versioning').compare_versions
config = require('../config')
broker = require("../broker")

DefinitionBase = require "./definition_base"

# provides basic validation, new lab definition is accepted if the 
# new definition version is > than the existing one

module.exports = class BasicDefinition extends DefinitionBase
	validate: ->
		current = @lab.current_definition

		# check lab definition version (existence of two same versions is enforce by unique 
		# compound key on definition shema - see model).

		if !current? or compare_versions(@definition.version, current.version)
			def_data = @definition
			def_data.lab = @lab

			lab_def = new Definition(def_data)
			lab_def.save (err) =>
				if err
					this.emit "refused", "Unable to save definition: #{err}"
				else
					console.log "accepted new lab definition version=#{def_data.version} for lab=#{@lab.name}"
					this.emit "accepted"
		else
			this.emit 'refused', 'Lab definition needs to have different version (consider increasing build number'

	release: (metadata = {}) ->
		# TODO use metadata for security/auditing/sign-off functionality
		direction = "release"

		if @lab.state is "pending"
			this.emit 'refused', "There is a pending change."
			return

		# if defined, compare, otherwise is always release
		if @lab.current_definition? 
			res = compare_versions(@lab.current_definition.version, @definition.version)

			if res < 0
				direction = "rollback"
			else if res == 0
				return this.emit 'refused', "Target lab definition is already deployed."
		
		#@lab.fire 'lock'

		job_data = 
			workflow: "BalanceLabWorkflow"
			data:
				lab:
					name: @lab.name
					token: @lab.token
				definition: @definition
				migration: direction

		# FIXME initiate release workflow
		req = broker.raw_dispatch job_data, config.get('taskeng')
		req.on 'data', (message) =>
			# once lab request is accepted switch to the new definition
			@lab.current_definition = @definition
			@lab.save (err) =>
				if err 
					this.emit "refused", "Unable to confirm current definition; lab incosistent: #{err}"
				else
					this.emit 'accepted', "Lab definition #{direction} requested"

		req.on 'error', (message) =>
			this.emit 'refused', "Lab definition #{direction} refused: unable to request migration (#{message})"
