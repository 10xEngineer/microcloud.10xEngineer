module.exports = exports = timestampPlugin = (schema) ->
  schema.add({
    created_at: {type: Date, default: Date.now}
    updated_at: {type: Date, default: Date.now}
    deleted_at: {type: Date, default: null}
  })

  schema.pre 'save', (next) ->
    this.updated_at = Date.now
    next()


