module.exports = ->

log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
async 		= require "async"
Pool		= mongoose.model 'Pool'

module.exports.index = (req, res, next) ->
	Pool
		.find({disabled: false})
		.select(name:1, _id:0)
		.exec (err, pools) ->
			res.send pools
