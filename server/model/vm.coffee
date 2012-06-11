mongoose = require "mongoose"

VmDescriptorSchema = new mongoose.Schema({
  # TODO define common 
})

VmSchema = new mongoose.Schema(
  uuid: {type: String, unique: true},
  state: {type: String, default: 'prepared'},
  template: String,
  server: String,
  pool: String,
  descriptor: [VmDescriptionSchema],

  # TODO make this re-usable
  meta: {
    created_at: Date
    updated_at: Date
  }
)

module.exports.register = mongoose.model 'Vm', VmSchema
