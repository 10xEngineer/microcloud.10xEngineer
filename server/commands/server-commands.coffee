module.exports = ->

log = require("log4js").getLogger()
commands = require("./commands")
mongoose = require("mongoose")
Provider = mongoose.model('Provider')
Hostnode = mongoose.model('Hostnode')
broker = require("../broker")

module.exports.create = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, doc) ->
    # FIXME hardcoded provider and options
    provider = 'vagrant'
    options = {
      env: "/Users/radim/Projects/10xeng/microcloud.10xEngineer/a_vagrant_machine"
    }

    broker.dispatch provider, 'start', options, (message) ->
      if message.status == 'ok'
        Hostnode.findOne {server_id: message.options.id}, (err,doc) ->
          if doc
            doc.token = message.options.token
            doc.meta.updated_at = Date.now()
            doc.save (err) ->
              if err
                log.error "Unable to save hostnode: #{err.message}"
                res.send 409, err.message
              else
                log.info "hostnode '#{doc.server_id}' saved"
                delete doc._id
                res.send doc
          else
            hostnode = new Hostnode(
              server_id : message.options.id
              hostname : message.options.hostname
              provider : provider
              token : message.options.token
              state : 'new'
            )
            hostnode.save (err) ->
              if err
                log.error "Unable to save hostnode: #{err.message}"

                res.send 409, err.message
              else
                log.info "hostnode '#{hostnode.server_id}' saved"
                delete hostnode._id
                res.send hostnode
      else
        res.send message

module.exports.show = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, doc) ->
    # FIXME hardcoded provider and options
    provider = 'vagrant'
    options = {
      id: req.params.server
      env: "/Users/radim/Projects/10xeng/microcloud.10xEngineer/a_vagrant_machine"
    }

    broker.dispatch provider, 'status', options, (message) ->
      res.send message

module.exports.destroy = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, doc) ->
    # FIXME hardcoded provider and options

    provider = 'vagrant'
    options = {
      id: req.params.server
      env: "/Users/radim/Projects/10xeng/microcloud.10xEngineer/a_vagrant_machine"
    }

    broker.dispatch provider, 'stop', options, (message) ->
      res.send message

    
# ==================================================================================================================================
module.exports.start = (req, res, next) ->
  log.info "starting a server on : " + req.params.destination
  child = commands.cli.execute_command("localhost", "./scripts/startserver.sh", [ req.params.destination ], (output) ->
    res.send output
  )
  child.stdout.on "data", (data) ->
    log.debug data

  child.stderr.on "data", (data) ->
    log.debug data

  child.on "exit", (code) ->
    log.debug "exiting startserver.sh"
    child.stdin.end()

  next()

# ==================================================================================================================================
module.exports.stop = (req, res, next) ->
  log.info "stopping a server " + req.params.server + " on : " + req.params.destination
  child = commands.cli.execute_command("localhost", "./scripts/stopserver.sh", [ req.params.destination ], (output) ->
    res.send output
  )
  child.stdout.on "data", (data) ->
    log.debug data

  child.stderr.on "data", (data) ->
    log.debug data

  child.on "exit", (code) ->
    log.debug "exiting stopserver.sh"
    child.stdin.end()

  next()

# ==================================================================================================================================
module.exports.status = (req, res, next) ->
  log.info "stopping a server " + req.params.server + " on : " + req.params.destination
  child = commands.cli.execute_command("localhost", "./scripts/getstatusserver.sh", [ req.params.destination ], (output) ->
    res.send output
  )
  child.stdout.on "data", (data) ->
    log.debug data

  child.stderr.on "data", (data) ->
    log.debug data

  child.on "exit", (code) ->
    log.debug "exiting stopserver.sh"
    child.stdin.end()

  next()

# ==================================================================================================================================
module.exports.restart = (req, res, next) ->
  log.info "restarting a server " + req.params.server + " on : " + req.params.destination
  child = commands.cli.execute_command("localhost", "./scripts/restartserver.sh", [ req.params.destination ])
  child.stdout.on "data", (data) ->
    log.debug data

  child.stderr.on "data", (data) ->
    log.debug data

  child.on "exit", (code) ->
    log.debug "exiting stopserver.sh"
    child.stdin.end()

  next()
