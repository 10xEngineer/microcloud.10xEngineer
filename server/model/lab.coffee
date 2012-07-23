log = require("log4js").getLogger()
mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"
Vm = mongoose.model 'Vm'
async     = require 'async'
broker = require '../broker'
notification = require '../utility/notification'

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
      # TODO make re-usable (vm_running, vm_allocated)
      vm_count = lab.definition.vms.length

      if vm_count == active_vms.length
        return "available"
      else
        return "pending"

  "available":
    start: (lab) ->
      Lab.emit 'start', lab.token

      return null

    vm_running: (lab, running_vms) ->
      vm_count = lab.definition.vms.length

      if vm_count == running_vms.length
        return "running"
      else
        # TODO available not appropriate (it's state change pending)
        return "available"

    vm_allocated: (lab, active_vms) ->
      log.debug "Notification out of order; lab already in state 'available'"

      return "available"

  "running":
    vm_allocated: (lab, active_vms) ->
      vm_count = lab.definition.vms.length

      if vm_count == active_vms.length
        return "available"
      else
        # TODO not really running (pending operation)
        return "running"

  "terminating": {}
  "terminated": {}

#
# methods
#
Lab.addListener 'start', (lab_token) ->
  mongoose.model("Lab")
    .findOne({token: lab_token})
    .populate("vms")
    .exec (err, lab) ->
      # TODO error handling
      lab.start lab

Lab.methods.start = (lab) ->
  async.waterfall [
    (next) ->
      Vm
        .find({lab: lab._id})
        .where('state', 'allocated')
        .populate("server")
        .exec (err, vms) ->
          if err
            next
              message: "Unable to load VMs for lab=#{lab.token}: #{err.message}"
          else 
            next null, vms
    (vms, next) ->
      async.forEach vms, (vm, cb) ->
        request = 
          id: vm.uuid
          server: vm.server.hostname

        req = broker.dispatch vm.server.type, 'start', request
        req.on 'data', (message) =>
          return cb

        req.on 'error', (message) =>
          return cb(new Error(message.options.reason), vm)
      , (err, vm) ->
        if err
          next "lab=#{lab.token} startup failed, unable to start vm=#{vm.uuid}: #{err.message}"
        else next null
  ], (err) ->
    if err
      log.error err.message
    else
      log.info "lab=#{lab.token} startup initiated"

#
# VM integration
#
Lab.addListener 'vmStateChange', (lab, vm, prev_state) ->
  action = "vm_#{vm.state}"

  vm_state = "available"
  switch vm.state
    when "allocated", "running" then vm_state = vm.state
    # TODO how to handle failing

  Vm
    .find({lab: lab._id})
    .where('state').equals(vm_state)
    .exec (err, vms) ->
      lab.fire(action, vms)
      
  notification.send text: "One of the required VMs for this lab (#{vm.uuid}) just changed its state '#{prev_state}' to '#{vm.state}'"
  
  log.debug "lab=#{lab.token} event=vmStateChange vm=#{vm.uuid} (#{prev_state} -> #{vm.state})"

Lab.addListener 'onEntry', (lab, prev_state) ->
  log.info "lab=#{lab.token} changed state to=#{lab.state}"

Lab.addListener 'onEntry:available', (lab, prev_state) ->
  notification.send method: 'removePendingNotification', id: 'vmAllocation'
  notification.send text: "Lab #{lab.token} is available."
  # triger lab start
  if lab.state == "available" && prev_state == "pending"
    lab.fire 'start'


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

