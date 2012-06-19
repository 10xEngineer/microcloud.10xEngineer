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
  

