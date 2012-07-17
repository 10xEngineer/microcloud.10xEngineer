module.exports = ->

mongoose = require("mongoose")
log = require("log4js").getLogger()
LabDefinition = mongoose.model("LabDefinition")
Vm = mongoose.model("Vm")
Lab = mongoose.model("Lab")
broker = require("../broker")
notification = require '../utility/notification'
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
  # TODO validate if body is present
  data = JSON.parse req.body

  # name is required
  if _.isUndefined(data["name"]) or data["name"] is ""
    res.send 406,
      reason: "Lab definition name is required."

    return

  # create/clone
  if _.isUndefined(data["parent"]) or data["parent"] is ""
    op = "create_repo"
  else
    op = "clone_repo"
    # FIXME retrieve git repository from parent lab definition
    # FIXME hardcoded for now
    data["repo"] = "git@github.com:10xEngineer/wip-lab-definition.git"

  async.waterfall [
    (next) ->
      lab_data = 
        name: data["name"]

      lab_def = new LabDefinition(lab_data)
      lab_def.save (err) ->
        if err
          next
            message: "Unable to create lab definition (#{err.message})"
            code: 500
        else next null, lab_def
    (lab_def, next) ->
      opts =
        repo: data.repo

      broker.dispatch 'git_adm', op, opts, (message) =>
        if message.status == "ok"
          repo = message.options.repo

          next null, lab_def, repo
    (lab_def, repo, next) ->
      lab_def.repo = repo
      lab_def.save (err) ->
        if err
          next 
            message: "Unable to associate GIT repository with lab definition (#{err.message})"
            code: 500
        else next null, lab_def
  ], (err, lab) ->
    if err
      res.send 500, 
        reason: err.message
    else
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
      notification.send text: "Finding lab definition #{req.params.lab_definition_id}"
      LabDefinition.findOne {name: req.params.lab_definition_id}, (err, lab_def) ->
        if err
          next
            message: "Can't load lab definition (#{err.message})"
            code: 409
        else next null, lab_def
    # create lab instance
    (lab_def, next) ->
      notification.send text: "Creating Lab"
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
      notification.send 
        text: "Microcloud is now preparing VMs required for the lab."
        stay: true
        id  : 'vmAllocation'
      async.forEach lab_def.vms, (vm_def, cb) ->
        # TODO add vm_type to lookup
        Vm.findAndModify {'state': 'prepared', 'vm_type': vm_def.vm_type}, [], {$set: {state: 'locked', lab: lab._id, vm_name: vm_def.vm_name}}, {}, (err, vm) ->
          if !vm
            return cb(new Error("No suitable VM available"))

          data = 
            id: vm.uuid
            server: vm.server.hostname

          broker.dispatch vm.server.type, 'allocate', data, (message) =>
            if message.status == 'ok'
              return cb()
            
            return cb(new Error(message.options.reason))
      , (err) ->
        if err
          log.error "VM allocation request failed for lab '#{lab.token}': #{err.message}"
          # TODO notify something to cleanup VMs (or something should just pick them up)
          next
            message: "Unable to allocate VM (#{err.message})"
            code: 409
        else
          next null, lab
  ], (err, lab) ->
    if err
      notification.send method: 'removePendingNotification', id: 'vmAllocation'
      log.error text = "Lab allocation failed: #{err.message}"
      notification.send
        text: text
        stayTime: 10000
      res.send err.code, err.message
    else
      log.info text = "lab=#{lab.token} action=allocate accepted"
      res.send lab

  
