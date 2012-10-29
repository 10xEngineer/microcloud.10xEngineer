module.exports = ->

log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
Template 	= mongoose.model("Template")

#
# Templates commands
#
module.exports.index = (req, res, next) ->
	Template
		.where("deleted_at").equals(null)
		.select(_id:0)
		.exec (err, templates) ->
			if err
				return next(new restify.InternalError("Unable to retrieve templates: #{err}"))

			res.json templates

module.exports.updates = (req, res, next) ->
	# FIXME not yet implemented
	res.send 500, {}