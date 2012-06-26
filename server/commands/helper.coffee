_     = require 'underscore'
log   = require('log4js').getLogger()

helper = 
  load : (@data) ->
  checkPresenceOf : (required, next) ->
    for attr in required
      if _.isUndefined(@data[attr]) or @data[attr] is ""
        next 
          msg : "Missing request attribute '#{attr}'"
          code: 400
    next()

for key, _fn of helper when _.isFunction(_fn) and key isnt 'load'
  do ->
    fn = _fn
    helper[key] = ->
      if _.isUndefined @data then log.warn """
      !!!You didn't load input data in the helper\nUsually something like `helpers.load JSON.parse req.body`!!!
      """
      fn.apply helper, arguments
    
module.exports = helper