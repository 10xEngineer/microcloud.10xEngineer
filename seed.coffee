mongoose = require("mongoose")
log = require("log4js").getLogger()
path = require("path")
config = require("./server/config")

# FIXME reuse config
mongoose.connect('mongodb://'+config.get('mongodb:host')+'/'+config.get('mongodb:dbName'))

# register models
# TODO shared logic to load all models
Provider = require("./server/model/provider").register
LabDefinition = require("./server/model/lab_definition").register


# shared logic
next_action = (actions) ->
  action = actions.shift()
  process.exit() if !action

  action(actions)

# load all seed files
require("fs").readdirSync("./server/db").forEach (file) -> 
  if path.extname(file) == ".coffee"
    basename = path.basename(file, ".coffee")

    log.info "seed_file=#{basename}"
    seed_module = require "./server/db/#{basename}"
    seed_module.seed()
