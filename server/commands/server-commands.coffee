module.exports = ->

log = require("log4js").getLogger()
commands = require("./commands")
mongoose = require("mongoose")
Provider = mongoose.model('Provider')
Hostnode = mongoose.model('Hostnode')
broker = require("../broker")

module.exports.index = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, provider) ->
    if err
      res.send 404, "Provider does not exist"
    if provider
      Hostnode.find {"provider": provider.name}, {_id:0}, (err, hostnodes) ->
        res.send hostnodes

module.exports.create = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, provider) ->
    if err
      log.error "Unable to get provider"
      res.send 409, err.message

    if provider
      broker.dispatch provider.service , 'start', provider.data, (message) ->
        if message.status == 'ok'
          # FIXME wtf? 
          Hostnode.find_by_server_id message.options.id, (err, hostnode) ->
            if hostnode
              hostnode.token = message.options.token
              hostnode.save (err) ->
                if err
                  log.error "Unable to save hostnode: #{err.message}"
                  res.send 409, err.message
                else
                  log.info "hostnode '#{hostnode.server_id}' saved"
                  delete hostnode._id
                  res.send hostnode
            else
              hostnode = new Hostnode(
                server_id : message.options.id
                hostname : message.options.hostname
                provider : provider.name
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
    else
      res.send 404, "No provider found."

#
# TODO how to periodically get server status
module.exports.show = (req, res, next) ->
  Hostnode.findOne {server_id: req.params.server}, (err, server) ->
    console.log server
    if err
      res.send 500, err

    if server
      res.send server
    else
      res.send 404, 'Server not found.'
  
module.exports.destroy = (req, res, next) ->
  Provider.for_server req.params.server, (err, provider) ->
    if err
      res.send 500, err

    if provider
      data = {
        id: req.params.server
      }
      broker.dispatch provider.name , 'stop', data, (message) ->
        res.send message
    else
      # TODO trigger housekeeping
      res.send 500, "No provider for server '#{req.params.server}'"

# TODO move to appropriate module (servers)
module.exports.notify = (req, res, next) ->
  data = JSON.parse(req.body)
  # FIXME verify data/action
  Hostnode.find_by_server_id req.params.server, (err, hostnode) ->
    if hostnode
      # FIXME process body to find action
      hostnode.fire data["action"], data.hostnode , (err) -> 
        if err
          console.log(err)

      res.send 200
    else
      log.error("Notification for invalid hostnode=#{req.params.server}")
      res.send 404, {}

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
