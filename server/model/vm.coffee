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
  # Mixed - dont' forget vm.markModified('descriptor')
  # http://mongoosejs.com/docs/schematypes.html#mixed
  descriptor: {}
)

Vm.plugin(timestamps)
Vm.plugin(state_machine, 'prepared')

#
# state machine
#
Vm.statics.paths = ->
  "prepared":
    # TODO reserve VM for given lab
    # not really in use right now (TODO)
    book: (vm, lab) ->
      console.log("vm=#{vm.uuid} reserved for lab=#{lab.token}")
      vm.lab = lab

      return "reserved"

    # TODO move under 'reserver' state later
    start: (vm, vm_data) ->
      vm.start(vm_data)

      return "running"

  "running":
    stop: (vm, vm_data) ->
      vm.descriptor.ip_addr = null
      vm.markModified('descriptor')
      
      return "allocated"

  "reserved": {}

  "allocated":
    start: (vm, vm_data) ->
      vm.start(vm_data)

      return "running"

Vm.statics.reserve = (vm, lab) ->
  vm.fire 'book', lab, (err) ->
    if err
      console.log "Unable to reserve vm=#{vm.uuid} (#{err})"

Vm.methods.start = (data) ->
  this.descriptor.ip_addr = data.ip_addr
  this.markModified('descriptor')

module.exports.register = mongoose.model 'Vm', Vm
