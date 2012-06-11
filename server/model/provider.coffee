mongoose = require 'mongoose'

Provider = new mongoose.Schema(
  name: String,
  payload: String,

  # TODO make this re-usable
  meta: {
    created_at: {type: Date, default: Date.now}
    updated_at: {type: Date, default: Date.now}
  }
)

module.exports = mongoose.model 'Provider', Provider
