config = require("nconf")
path = require 'path'
log	= require('log4js').getLogger()

config
  .env()

config.defaults 
	NODE_ENV: 'development'

if config.get('NODE_ENV') == 'development'
	configPath = path.resolve __dirname, "../config/gateway.json"
else
	configPath = "/etc/10xlabs/gateway.json"

log.info "config file=#{configPath}"

# initialize config
config
  .argv()
  .env()
  .file file: configPath

get = (key,callback)->
	config.get(config.get('NODE_ENV')+':'+key)

exports.get = get
