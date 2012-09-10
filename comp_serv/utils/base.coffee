module.exports = ->

moduleKeywords = ['included', 'extended']

class Base  
  @include: (obj) ->
    throw new Error 'include(obj) requires obj' unless obj
    for key, value of obj.prototype when key not in moduleKeywords
        @::[key] = value
    included.apply(this) if included = obj.included
    this

module.exports = Base