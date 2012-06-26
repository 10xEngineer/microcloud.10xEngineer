emitter = require('events').EventEmitter
_       = require 'underscore'
log     = require('log4js').getLogger()

module.exports = exports = stateMachinePlugin = (schema, init_with) ->
  schema.add
    state: {type: String, default: init_with}

  schema.methods.fire = (event, data = {}, _callback = ->) ->
    callback = (err) ->
      log.warn err if err
      _callback err
      
    unless _.isFunction schema.statics["paths"]
      return callback new Error "Not a valid state machine object!"

    paths = schema.statics["paths"]()

    unless paths.hasOwnProperty this.state
      return callback new Error "Invalid state '#{this.state}'"

    current = paths[this.state]

    unless current.hasOwnProperty event
      return callback new Error "Event not found '#{event}'"

    action      = current[event]
    prev_state  = this.state

    schema.emit 'beforeTransition', this, event
    
    if new_state = action this, data
      unless paths.hasOwnProperty new_state
        return callback new Error "Unable to change state; '#{this.state}' -> '#{new_state}' not valid transition"

      this.state = new_state
      this.save (err) =>
        callback err
        unless err
          schema.emit 'afterTransition', this, prev_state
          if new_state isnt prev_state
            schema.emit "onEntry:#{new_state}", this 
            schema.emit "onEntry", this 
        
