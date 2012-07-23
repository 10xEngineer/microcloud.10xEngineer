module.exports = ->

log = require("log4js").getLogger()

module.exports = class DefinitionBase
	constructor: (@lab, @definition) ->

	validate: (cb)->
		console.log '--- in validate'

		return cb() 


