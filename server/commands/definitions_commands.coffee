module.exports = ->

mongoose = require("mongoose")
log = require("log4js").getLogger()
LabDefinition = mongoose.model("LabDefinition")
Vm = mongoose.model("Vm")
Lab = mongoose.model("Lab")
broker = require("../broker")
_         = require 'underscore'
async     = require 'async'

#
# Lab definition
#

module.exports.index = (req, res, next) ->
  LabDefinition.find {}, {_id: 0, "meta": 0}, (err, doc) ->
    res.send doc

module.exports.show = (req, res, next) ->
  LabDefinition.findOne {name: req.params.lab_definition_id}, (err, doc) ->
    if doc
      res.send doc
    else
      res.send 404, 'Lab definition not found'
  
module.exports.create = (req, res, next) ->
  data = JSON.parse req.body

  lab = new LabDefinition(data)
  lab.save (err) ->
    if err
      log.error "Unable to save lab: #{err.message}"

      res.send 409, err.message
    else
      log.info "Lab definition '#{lab.name}' saved"
      res.send lab

module.exports.destroy = (req, res, next) ->
  log.warn "action=destroy lab_definition='#{req.params.lab_definition_id}"
  # TODO soft delete only
  LabDefinition.remove {name: req.params.lab_definition_id}, ->
      res.send 200

#
# Lab provisioning
#

module.exports.allocate = (req, res, next) ->
  # TODO lab is created for (course, user); need to validate existing
  # TODO hardcoded username - need to build proper authentication
  user = "anonymous-123"

  async.waterfall [
    # find lab definition
    (next) ->
      res.everyone.now.log text: "Finding lab definition #{req.params.lab_definition_id}"
      LabDefinition.findOne {name: req.params.lab_definition_id}, (err, lab_def) ->
        if err
          next
            message: "Can't load lab definition (#{err.message})"
            code: 409
        else next null, lab_def
    # create lab instance
    (lab_def, next) ->
      res.everyone.now.log text: "Creating Lab"
      lab = new Lab
      lab.definition = lab_def
      lab.save (err) ->
        if err
          next
            message: "Unable to save lab instance (#{err.message})"
            code: 409
        else next null, lab_def, lab
    # TODO temporary load new lab (definition is not populated in last step; any way how to fix it?)
    (lab_def, lab, next) ->
      Lab
        .findOne({'token': lab.token})
        .populate('definition')
        .exec (err, _lab) ->
          if err
            next
              message: "Unable to retrieve lab: #{err.message}"
              code: 500
          else next null, lab_def, lab
    # allocate required VM from pool
    (lab_def, lab, next) ->
      res.everyone.now.log text: "Allocating required VMs"
      # Nowjs should know about it once
      Vm.addListener 'afterTransition', callback = (vm, prev_state) ->
        res.everyone.now.log 
          text: "VM=#{vm.uuid} changed state from=#{prev_state} to=#{vm.state}"
          stay: false
          stayTime: 3000
        Vm.removeListener 'afterTransition', callback
      
      async.forEach lab_def.vms, (vm_def, cb) ->
        Vm.findAndModify {'state': 'prepared'}, [], {$set: {state: 'locked', lab: lab._id, vm_name: vm_def.vm_name}}, {}, (err, vm) ->
          if !vm
            return cb(new Error("No suitable VM available"))

          data = 
            id: vm.uuid
            # FIXME get the server hostname from vm.server.hostname
            server: 'no.hostname.lab.allocate'

          broker.dispatch 'lxc', 'allocate', data, (message) =>
            if message.status == 'ok'
              return cb()
            
            return cb(new Error(message.options.reason))
      , (err) ->
        if err
          log.error "VM/LXC allocation request failed for lab '#{lab.token}': #{err.message}"
          # TODO notify something to cleanup VMs (or something should just pick them up)
          next
            message: "Unable to allocate VM (#{err.message})"
            code: 409
        else
          next null, lab
  ], (err, lab) ->
    if err
      log.error text = "Lab allocation failed: #{err.message}"
      res.everyone.now.log 
        text: text
        stayTime: 10000
      res.send err.code, err.message
    else
      log.info text = "lab=#{lab.token} action=allocate accepted"
      res.everyone.now.log 
        text: text
        stayTime: 10000
      res.send lab

  
