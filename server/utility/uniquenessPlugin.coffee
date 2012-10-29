module.exports = exports = (schema, options) ->
  schema.statics.checkUniquenessOf = (fields, cb) ->
    @find().or(fields).exec (err, docs) =>
      for doc in docs
        unless doc.deleted_at then return cb 
          msg : "There is active document #{@modelName} with the same name '#{doc.name}'"
          code: 400
      cb()