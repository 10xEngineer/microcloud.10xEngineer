module.exports = -> 

restify 	= require("restify")
log 		= require("log4js").getLogger()
async 		= require("async")
mongoose	= require("mongoose")
Microcloud 	= mongoose.model 'Microcloud'

module.exports.index = (req, res, next) ->
	Microcloud
		.where("deleted_at").equals(null)
		.select(
			_id: 0, 
			"created_at": 0
			"updated_at": 0
			"deleted_at": 0
			)
		.exec (err, microclouds) ->
			if err
				return callback(new restify.InternalError("Unable to retrieve microclouds: #{err}"))

			res.send microclouds

