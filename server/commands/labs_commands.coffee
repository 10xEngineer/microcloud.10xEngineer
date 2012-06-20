module.exports = ->

mongoose = require("mongoose")
log = require("log4js").getLogger()
LabDefinition = mongoose.model("LabDefinition")
Vm = mongoose.model("Vm")
Lab = mongoose.model("Lab")

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
  LabDefinition.findOne {name: req.params.lab_definition_id}, (err, lab_def) ->
    if lab_def
      # TODO create lab (if it doesn't exists)
      lab = new Lab
      lab.save (err) ->
        # TODO err handling
        Vm.where('state', 'prepared').limit(2).exec (err, vms) ->
          if lab_def.vms.length == vms.length
            Vm.reserve vm,lab for vm in vms
            
            
            # VMs are available
            # TODO allocate both VMs

            res.send 200, "test"
          else
            # FIXME dynamic allocation
            res.send 500, "On-demand VM allocation not available (yet)."
    else
      res.send 404, 'Lab definition not found'


  
