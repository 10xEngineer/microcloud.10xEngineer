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
# Lab management
#
module.exports.show = (req, res, next) ->
  Lab.findOne {token: req.params.lab_id}, (err, lab) ->
    res.send lab

