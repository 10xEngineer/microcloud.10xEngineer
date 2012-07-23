_ = require 'underscore'
# labs/versioning.coffee
module.exports = ->

defs = ['major', 'minor', 'build', 'status']
statuses = ['alpha', 'beta', 'rc', 0]
class Version 
  constructor: (version) ->
    versionArray = version.split '.'
    _.each defs, (def, index) =>
      # Convert number string to Integer ("1" -> 1)
      val = versionArray[index]
      # If val is a word, then parseInt returns NaN
      # NaN is NaN returns false, therefore status
      # wont pass this condition
      if +val is parseVal = parseInt val, 10
        val = parseVal
      # status ("Alpha", "Beta", ..) stays as string
      # but lower case ("ALPHA" -> "alpha")
      else if _.isString val
        val = val.toLowerCase()
      @[defs[index]] = val ? 0

module.exports.compare_versions = (ver1, ver2) ->
  ver1 = new Version ver1
  ver2 = new Version ver2
  result = 0
  _.find defs, (def) ->
    def1 = ver1[def]
    def2 = ver2[def]
    # Both are numbers, compare
    if _.isNumber(def1) and _.isNumber(def2)
      result = 
        if def1 > def2 then 1
        else if def1 < def2 then -1
        else 0
    # At least one of them is string
    else if _.isString(def1) or _.isString(def2)
      statusVal1 = statuses.indexOf def1
      statusVal2 = statuses.indexOf def2
      result = 
        if statusVal1 > statusVal2 then 1
        else if statusVal1 < statusVal2 then -1
        else 0
    # If result changes, versions are different
    # and the _.find loop can be terminated (by returning true)
    if result isnt 0 
      return true
    else 
      return false
      
  return result