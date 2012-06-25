mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"
state_machine = require "../utility/state_plugin"
Vm = mongoose.model "Vm"

ObjectId = mongoose.Schema.ObjectId

Lab = new mongoose.Schema({
  token: String,
  definition: ObjectId,
  # TODO to be defined later
  user: String,
  terminal_server: String,
  lab_attrs: {}
})

Lab.plugin(timestamps)
Lab.plugin(state_machine, 'new')

#
# State machine
#
Lab.statics.paths = ->
  "new":
    allocate: (lab, lab_def) ->
      console.log "---- lab allocate"

      return "pending"

  "pending":
    make_available: (lab) ->
      console.log "--- lab allocation finished"

      return "available"

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
Lab.addListener 'vmStateChange', (vm, prev_state, state) ->
  log.info "lab notified about vm=#{vm.uuid} change (#{prev_state} -> #{state})"

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

