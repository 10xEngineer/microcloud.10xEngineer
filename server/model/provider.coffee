mongoose = require 'mongoose'

ProviderDataSchema = new mongoose.Schema({
})

ProviderSchema = new mongoose.Schema(
  name: {type: String, unique: true},
  service: String,
  data: {env: String},

  # TODO make this re-usable
  meta: {
    created_at: {type: Date, default: Date.now}
    updated_at: {type: Date, default: Date.now}
  }
)

module.exports.register = mongoose.model 'Provider', ProviderSchema
