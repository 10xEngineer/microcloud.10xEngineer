mongoose = require "mongoose"

VmSchema = new mongoose.Schema(
  uuid: {type: String, unique: true},
  state: {type: String, default: 'prepared'},
  vm_type: String,
  server: String,
  pool: String,
  descriptor: {env: String},

  # TODO make this re-usable
  meta: {
    created_at: Date
    updated_at: Date
  }
)

module.exports.register = mongoose.model 'Vm', VmSchema
