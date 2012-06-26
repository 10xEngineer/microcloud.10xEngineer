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
  # TODO 
  #      (for starter - just pick first two available VMs)
  #      need to have pool of VMs
  #      allocate them (on same server)
  # TODO hardcoded username - need to build proper authentication
  user = "anonymous-123"

  async.waterfall [
    # find lab definition
    (next) ->
      LabDefinition.findOne {name: req.params.lab_definition_id}, (err, lab_def) ->
        if err
          next
            message: "Can't load lab definition (#{err.message})"
            code: 409
        else next null, lab_def
    # create lab instance
    (lab_def, next) ->
      lab = new Lab
      lab.definition = lab_def
      lab.save (err) ->
        if err
          next
            message: "Unable to save lab instance (#{err.message})"
            code: 409
        else next null, lab_def, lab

    # allocate required VM from pool
    # TODO pools are not implemented (yet), will pick any prepared VMs at the moment
    (lab_def, lab, next) ->
      async.forEach lab_def.vms, (vm_def, cb) ->
        Vm.findAndModify {'state': 'prepared'}, [], {$set: {state: 'locked', lab: lab._id, vm_name: vm_def.vm_name}}, {}, (err, vm) ->
          if !vm
            return cb(new Error("No suitable VM available"))

          # TODO right now allocate is noop
          # TODO service name should come up from vm definition (will allow multi-OS support)
          data = 
            id: vm.uuid
            # FIXME get the server hostname from vm.server.hostname
            server: 'no.hostname.lab.allocate'

          broker.dispatch 'lxc', 'allocate', data, (message) ->
            if message.status == 'ok'
              vm.fire 'allocate', {}, (err) ->
                if err
                  return cb(new Error("Unable to confirm VM allocation (#{err.message})"))

                return cb()
            else
              return cb(new Error("VM/LXC allocation failed #{message.options.reason}"))
      , (err) ->
        if err
          log.error "VM allocation failed for lab '#{lab.token}': #{err.message}"
          # TODO notify something to cleanup VMs (or something should just pick them up)
          next
            message: "Unable to allocate VM (#{err.message})"
            code: 409
        else
          next null, lab

    # TODO starts instances by default (lxc::start)
  ], (err, lab) ->
    if err
      log.error "Lab allocation failed: #{err.message}"
      res.send err.code, err.message
    else
      log.info "Lab '#{lab.token}' created"
      res.send lab

  
