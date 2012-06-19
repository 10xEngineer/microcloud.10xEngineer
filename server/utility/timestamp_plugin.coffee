module.exports = exports = timestampPlugin = (schema) ->
  schema.add({
    meta: {
      created_at: {type: Date, default: Date.now}
      updated_at: {type: Date, default: Date.now}
    }
  })

  schema.pre 'save', (next) ->
    this.updated_at = Date.now
    next()


