mongoose = require("mongoose")
log = require("log4js").getLogger()
path = require("path")

# FIXME reuse config
mongoose.connect('mongodb://localhost/microcloud_dev')

# register models
Provider = require("./server/model/provider").register


# shared logic
next_action = (actions) ->
  action = actions.shift()
  process.exit() if !action

  action(actions)

# 
# seed functions
#

vagrant = (next) ->
  # vagrant provider
  vagrant_root = path.join(path.dirname(__filename), "a_vagrant_machine/")

  vagrant_def = {
    name: 'vagrant',
    service: 'vagrant',
    data: [{'env': vagrant_root}]
  }

  vagrant = new Provider(vagrant_def)
  vagrant.save (err) ->
    if err
      console.log "Unable to create vagrant provider: #{err.message}"

    next_action(next)

actions = [vagrant]
next_action(actions)
