config = require("nconf")
path = require 'path'

configPath = path.resolve __dirname, "../config/gateway.json"

# initialize config
config
  .argv()
  .env()
  .file file: configPath

config.defaults 
	NODE_ENV: 'development'

get = (key,callback)->
	config.get(config.get('NODE_ENV')+':'+key)

exports.get = get
