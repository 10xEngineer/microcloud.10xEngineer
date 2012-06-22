mongoose = require 'mongoose'

VMDefinition = new mongoose.Schema({
  vm_name: String,
  vm_type: String,
  hostname: String,
  run_list: [String],
  vm_attrs: {},
})

# TODO soft deletes and versioning
LabDefinitionSchema = new mongoose.Schema(
  name: {type: String, unique: true},
  token: String,
  vms: [VMDefinition]

  # TODO make this re-usable (include timestamp plugin)
  meta: {
    created_at: {type: Date, default: Date.now}
    updated_at: {type: Date, default: Date.now}
  }
)

module.exports.register = mongoose.model 'LabDefinition', LabDefinitionSchema
