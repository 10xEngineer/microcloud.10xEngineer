log = require("log4js").getLogger()
mongoose = require "mongoose"
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"
ObjectId = mongoose.Schema.ObjectId;
async     = require 'async'

Vm = new mongoose.Schema(
  uuid: {type: String, unique: true},
  state: {type: String, default: 'prepared'},
  lab: {type:ObjectId, default: null, ref: 'Lab', auto:true},
  vm_type: String,
  vm_name: String,
  server: {type: ObjectId, ref: 'Hostnode', auto: true}
  pool: { type: ObjectId, ref: 'Pool' }
  # Mixed - dont' forget vm.markModified('descriptor')
  # http://mongoosejs.com/docs/schematypes.html#mixed
  descriptor: {}
)

Vm.plugin(timestamps)
Vm.plugin(state_machine, 'prepared')

Vm.statics.findAndModify = (query, sort, doc, options, callback) ->
  this.collection.findAndModify query, sort, doc, options, (err, raw_vm) ->
    if err then return callback err, raw_vm
    if raw_vm 
      mongoose.model("Vm")
        .findOne(uuid: raw_vm.uuid)
        .populate("lab")
        .populate("server")
        .exec callback
    else
      return callback()

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

      return "available"

    allocate: (vm) ->
      log.warn "Invalid event :alocate_xxx for VM in state=prepared"

      return "available"

    destroy: (vm) ->
      return "destroyed"

  "pending":
    lock: (vm) ->
      "locked"

  "locked":
    bootstrapped: (vm) ->
      # FIXME continue how to get lab instance
      #vm.lab.vms.push(vm.id);
      #vm.lab.save (err) ->
      #  if err
      #    log.error("Unable to add vm to lab=#{lab.token}")

      return "available"

  "reserved": {}

  "available":
    start: (vm, vm_data) ->
      vm.start(vm_data)

      return "available"

    destroy: (vm) ->
      return "destroyed"

  # TODO decomission - can't move from available (chef provisioned to running), doesn't make
  #      sense.
    stop: (vm, vm_data) ->
      vm.descriptor.ip_addr = null
      vm.markModified('descriptor')
      
      return "destroyed"

  "destroyed": {}


Vm.statics.reserve = (vm, lab) ->
  vm.fire 'book', lab, (err) ->
    if err
      console.log "Unable to reserve vm=#{vm.uuid} (#{err})"

Vm.methods.start = (data) ->
  this.descriptor.ip_addr = data.ip_addr
  this.markModified('descriptor')

Vm.addListener 'afterTransition', (vm, prev_state) ->
  # FIXME-events start/stop event notification

  # notify hostnode
  if vm.server && mongoose.model("Hostnode")
    vm.server.schema.emit('vmStateChange', vm.server, vm, prev_state)
    
  # notify associated lab
  if vm.lab && mongoose.model("Lab")
    # TODO reload lab as the original object doesn't have vm.lab.definition populated or
    #      make sure the target lab is handling the definition retrieval
    vm.lab.schema.emit('vmStateChange', vm.lab, vm, prev_state)
   
  log.info "vm=#{vm.uuid} changed state from=#{prev_state} to=#{vm.state}"

module.exports.register = mongoose.model 'Vm', Vm
