crypto 		= require 'crypto'
module.exports.random = (length = 6) ->
	crypto.randomBytes(length, function(ex, buf) {
  		return buf.toString('hex');
	});