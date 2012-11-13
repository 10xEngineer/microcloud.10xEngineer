log 		= require("log4js").getLogger()
mongoose 	= require("mongoose")
cronJob 	= require("cron").CronJob
Machine		= mongoose.model "Machine"

archiveMachines = () ->
	job = new cronJob
		cronTime: "0 */5 * * * *"
		onTick: () ->
			Machine.archive()			
		start: true

module.exports.setup = () ->
	archiveMachines()