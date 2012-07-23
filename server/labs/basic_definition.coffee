module.exports = ->

mongoose = require "mongoose"
Definition = mongoose.model "Definition"
compare_versions = require('./versioning').compare_versions

DefinitionBase = require "./definition_base"

# provides basic validation, new lab definition is accepted if the 
# new definition version is > than the existing one

module.exports = class BasicDefinition extends DefinitionBase
	constructor: (lab, definition) ->
		super(lab, definition)

	validate: ->
		current = @lab.current_definition

		if current is undefined or compare_versions(@definition.version, current.version)
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
