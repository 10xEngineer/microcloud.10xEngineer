module.exports = ->

mongoose = require "mongoose"
Definition = mongoose.model "Definition"

DefinitionBase = require "./definition_base"

# provides basic validation, new lab definition is accepted if the 
# new definition version is > than the existing one

module.exports = class BasicDefinition extends DefinitionBase
	constructor: (lab, definition) ->
		super(lab, definition)

	validate: ->
		# TODO compare versions if > 0
		if @lab.current_version is undefined 
			def_data = @definition
			def_data.lab = @lab

			lab_def = new Definition(def_data)
			lab_def.save (err) =>
				if err
					this.emit "refused", "Unable to save definition: #{err}"
				else
					this.emit "accepted"
		else
			this.emit 'refused', 'Lab definition needs to have different version (consider increasing build number'
