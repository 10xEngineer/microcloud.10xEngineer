config = require("nconf")

#
# misc TODOs
# TODO valid content types (accepts)
# TODO providers - responses should be improved / standardized
# TODO zmq timeouts

# initialize config
config.argv.env
config.file({file: "./server/config.json"})

config.defaults(
	'NODE_ENV': 'development',
	'broker': 'ipc:///tmp/mc.broker'
)

get = (key,callback)->
	config.get(config.get('NODE_ENV')+':'+key)

exports.get = get