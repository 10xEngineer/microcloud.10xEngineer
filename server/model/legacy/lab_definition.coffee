mongoose = require 'mongoose'
timestamps = require "../utility/timestamp_plugin"

VMDefinition = new mongoose.Schema({
  vm_name: String,
  vm_type: String,
  hostname: String,
  run_list: [String],
  vm_attrs: {},
})

# TODO soft deletes and versioning
LabDefinition = new mongoose.Schema(
  name: {type: String, unique: true},
  token: String,
  repo: String,

  metadata: {},
  vms: [VMDefinition]
)

LabDefinition.plugin(timestamps)

module.exports.register = mongoose.model 'LabDefinition', LabDefinition
