log = require("log4js").getLogger()
mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"
Vm = mongoose.model "Vm"

ObjectId = mongoose.Schema.ObjectId

Lab = new mongoose.Schema({
  token: String,
  definition: {type: ObjectId, ref: 'LabDefinition'}
  # TODO to be defined later
  user: String,
  terminal_server: String,
  lab_attrs: {}
  vms: [{type: ObjectId, ref: 'Vm'}]
})

Lab.plugin(timestamps)
Lab.plugin(state_machine, 'pending')

#
# State machine
#
Lab.statics.paths = ->
  "pending":
    vm_allocated: (lab, active_vms) =>
      vm_count = lab.definition.vms.length

      if vm_count == active_vms.length
        return "available"
      else
        return "pending"

    # TODO vm_running should really go under 'available', but right now allocation is synchronous, 
    #      rather than notification based.
    vm_running: () ->
      console.log '--- in vm_running'

  "available":
    start: (lab) ->
      console.log "--- lab start requested"

      return "running"

  "running":
    terminate: (lab) ->
      console.log "--- lab terminating..."

      return "terminating"

  "terminating": {}
  "terminated": {}


#
# VM integration
#
Lab.addListener 'vmStateChange', (lab, vm, prev_state) ->
  action = "vm_#{vm.state}"

  Vm
    .find({lab: lab._id})
    .where('state').equals(vm.state)
    .exec (err, vms) ->
      lab.fire(action, vms)

  log.debug "lab=#{lab.token} event=vmStateChange vm=#{vm.uuid} (#{prev_state} -> #{vm.state})"

Lab.addListener 'onEntry', (lab, prev_state) ->
  log.info "lab=#{lab.token} changed state to=#{lab.state}"



# 
# lab token generator
#
tokenGenerator = (schema, callback) ->
  require("crypto").randomBytes 4, (ex,buf) ->
    token = buf.toString('hex')

    schema.path("token").set(token)

Lab.pre 'save', (next) ->
  lab = this
  if !this.token
    require("crypto").randomBytes 4, (ex,buf) ->
      lab.token = buf.toString('hex')
      next()
  else
    next()


module.exports.register = mongoose.model 'Lab', Lab

