crypto 		= require 'crypto'

module.exports.random = (callback, results) ->
	crypto.randomBytes 6, (ex, buf) ->
  		return callback(null, buf.toString('hex'))
