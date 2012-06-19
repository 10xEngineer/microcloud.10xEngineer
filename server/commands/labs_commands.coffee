module.exports = ->

mongoose = require("mongoose")
log = require("log4js").getLogger()
LabDefinition = mongoose.model("LabDefinition")

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
  LabDefinition.remove {name: req.params.lab_definition_id}, ->
      res.send 200
