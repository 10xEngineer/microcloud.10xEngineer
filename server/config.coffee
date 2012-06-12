config = require("nconf")

# initialize config
config.argv.env
config.file({file: "./server/config.json"})

config.defaults(
	'NODE_ENV': 'development',
)

get = (key,callback)->
	config.get(config.get('NODE_ENV')+':'+key)

exports.get = get