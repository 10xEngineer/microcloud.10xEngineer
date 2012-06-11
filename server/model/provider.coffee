mongoose = require 'mongoose'

Provider = new mongoose.Schema(
  name: {type: String, unique: true},
  payload: String,

  # TODO make this re-usable
  meta: {
    created_at: {type: Date, default: Date.now}
    updated_at: {type: Date, default: Date.now}
  }
)

module.exports.register = mongoose.model 'Provider', Provider
