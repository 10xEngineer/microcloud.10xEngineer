emitter = require('events').EventEmitter
_       = require 'underscore'

err_call = (callback, err) ->
  if callback
    return callback(err)
  else
    return
  

module.exports = exports = stateMachinePlugin = (schema, init_with) ->
  schema.add({
    state: {type: String, default: 'new'}
  })

  schema.methods.fire = (event, data = {}, callback) ->
    # TODO around transition wrapper
    if typeof schema.statics["paths"] != 'function'
      return err_call(callback, new Error("Not a valid state machine object!"))

    paths = schema.statics["paths"]()

    if !paths.hasOwnProperty(this.state)
      return err_call(callback, new Error("Invalid state '#{this.state}'"))

    current = paths[this.state]

    if not current.hasOwnProperty(event)
      return err_call(callback, new Error("Event not found '#{event}'"))

    action = current[event]
    prev_state = this.state

    schema.emit('beforeTransition', this, event)
    new_state = action(this, data)
    schema.emit('afterTransition', this, prev_state)
    schema.emit('onEntry', this) if new_state is "running"

    if new_state
      if !paths.hasOwnProperty(new_state)
        return err_call(callback, new Error("Unable to change state; '#{this.state}' -> '#{new_state}' not valid transition"))

      this.state = new_state
      this.save (err) ->
        return err_call(callback, err)

    return


