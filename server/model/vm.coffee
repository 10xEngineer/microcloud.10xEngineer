mongoose = require "mongoose"
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"
ObjectId = mongoose.Schema.ObjectId;

Vm = new mongoose.Schema(
  uuid: {type: String, unique: true},
  state: {type: String, default: 'prepared'},
  lab: {type:ObjectId, default: null},
  vm_type: String,
  server: String,
  pool: String,
  descriptor: {env: String}
)

Vm.plugin(timestamps)
Vm.plugin(state_machine, 'prepared')

#
# state machine
#
Vm.statics.paths = ->
  "prepared":
    # reserve VM for given lab
    book: (vm, lab) ->
      console.log("vm=#{vm.uuid} reserved for lab=#{lab.token}")
      vm.lab = lab

      return "reserved"

    # move under reserved state
    start: (vm, vm_data) ->
      vm.state = 'running'
      vm.descriptor.ip_addr = vm_data.ip_addr

      return "running"

  "reserved": {}

  "allocated":
    something: (vm, lab) ->
      console.log("ping/pong")

  "running": {}

Vm.statics.reserve = (vm, lab) ->
  vm.fire 'book', lab, (err) ->
    if err
      console.log "Unable to reserve vm=#{vm.uuid} (#{err})"

module.exports.register = mongoose.model 'Vm', Vm
