mongoose = require 'mongoose'

Hostnode = new mongoose.Schema(
  hostname: String
  provider: Provider
  template: String

  # TODO make this re-usable
  meta: {
    created_at: Date
    updated_at: Date
  }
)
