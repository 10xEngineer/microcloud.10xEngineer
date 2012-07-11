_     = require 'underscore'

class Redis
  constructor: ({@writer, @reader}) ->
    @setWriter @writer
  setWriter: (@writer, strict = false) ->
    if not strict and (_.isUndefined(@reader) or _.isNull(@reader))
      @reader = @writer
  setReader: (@reader) ->
    
  # Reader functions
  readerFns = ['get']
  # Writer functions
  writerFns = ['set', 'mset', 'append']
  do ->
    _.each readerFns, (fn) ->
      Redis::[fn] = -> @reader[fn].apply @reader, arguments
    _.each writerFns, (fn) ->
      Redis::[fn] = -> @writer[fn].apply @writer, arguments

module.exports = Redis