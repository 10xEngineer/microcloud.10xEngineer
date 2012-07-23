module.exports = ->

log = require("log4js").getLogger()
EventEmitter = require('events').EventEmitter
Base = require "./base"

module.exports = class DefinitionBase extends Base
	@include EventEmitter

	constructor: (@lab, @definition) ->
		EventEmitter.call @

	validate: ->
		# refuse by default; has to be overriden by sub-class implementation
		this.emit 'refused', "DefinitionBase has to be overriden with custom logic."

	release: (metadata = {}) ->
		# refuse by default; has to be overriden by sub-class implementation
		this.emit 'refused', "DefinitionBase has to be overriden with custom logic."

