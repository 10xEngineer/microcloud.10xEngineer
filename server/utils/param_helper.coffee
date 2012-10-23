_     	= require 'underscore'
log   	= require('log4js').getLogger()
restify	= require 'restify'

helper = 
  checkPresenceOf : (data, required, next) ->
    for attr in required
      if _.isUndefined(data[attr]) or data[attr] is ""
        return next(new restify.PreconditionFailedError("Missing attribute '#{attr}'"))

    next()

module.exports = helper