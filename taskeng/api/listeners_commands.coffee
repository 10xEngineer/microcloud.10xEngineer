log = require("log4js").getLogger()

module.exports.create_event = (runner, req, res, next) ->
	try
		data = JSON.parse req.body if req.body
	catch error
		return res.send 406, 
			reason: "Invalid request data: #{error}"

	runner.processEvent req.params.id, null, data, (err) ->
		if err
			res.send {}
		else
			res.send 404, err
