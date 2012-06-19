mongoose = require "mongoose"
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"

Vm = new mongoose.Schema(
  uuid: {type: String, unique: true},
  state: {type: String, default: 'prepared'},
  vm_type: String,
  server: String,
  pool: String,
  descriptor: {env: String}
)

Vm.plugin(timestamps)
Vm.plugin(state_machine, 'prepared')

Vm.statics.paths = ->
  "prepared":
    book: ->
      console.log("confirmed xxx!")

      return "reserved"
  "reserved":
    confirm: ->
      console.log("confirmed??")
      return "allocated"

  "allocated":
    something: ->
      console.log("ping/pong")

Vm.statics.reserve = (vm, lab) ->
  console.log "About to reserver"
  console.log vm

module.exports.register = mongoose.model 'Vm', Vm
