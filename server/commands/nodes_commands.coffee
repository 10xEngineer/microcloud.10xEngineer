module.exports = ->

log       = require("log4js").getLogger()
commands  = require("./commands")
mongoose  = require("mongoose")
Provider  = mongoose.model('Provider')
Hostnode  = mongoose.model('Hostnode')
Vm  = mongoose.model('Vm')
broker    = require("../broker")
helper    = require("./helper")
async     = require 'async'
restify   = require 'restify'

module.exports.index = (req, res, next) ->
  Hostnode.find (err, hostnodes) ->
    if err
      return helper.handlerErr res, err
    res.send hostnodes
    
module.exports.create = (req, res, next) ->
  Provider.findOne {name: req.params.provider}, (err, provider) ->
    if err
      log.error "Unable to get provider"
      res.send 409, err.message

    if provider
      req = broker.dispatch provider.service, 'start', provider, (message) ->
      req.on 'data', (message) ->
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
              type : provider.handler
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
      req.on 'error', (message) ->
          res.send message
    else
      res.send 404, "No provider found."

#
# TODO how to periodically get server status
module.exports.show = (req, res, next) ->
  Hostnode.findOne {server_id: req.params.node_id}, (err, node) ->
    if err
      res.send 500, err

    if node
      res.send node
    else
      res.send 404, 'Node not found.'
  
module.exports.destroy = (req, res, next) ->
  getHostnode = (next) ->
    Hostnode
      .findOne({server_id: req.params.node_id})
      .exec (err, hostnode) ->
        unless hostnode
          return next 
            code: 404
            message: "No hostnode '#{req.params.node_id}'"

        next null, hostnode

  allVMs = (next, results) ->

    Vm
      .find({server: results.getHostnode._id})
      .exec (err, vms) ->
        if err
          return next
            code: 500
            messages: "Unable to collect VMs; reason=#{err.message}"

        next null, vms

  verifyVMs = (next, results) ->
    for vm in results.allVMs
      if vm.state == 'allocated'
        return next 
          code: 406
          message: "Unable to destroy hostnode=#{req.params.node_id} reason='VMs active'"

    next null

  destroyVMs = (next, results) ->
    # FIXME universal way how to trigger internal object state changes?
    client = restify.createJsonClient
      url: 'http://localhost:8080'

    for vm in results.allVMs
      client.del "/vms/#{vm.uuid}", (err, req, res) ->
        if err
          log.warn "Unable to delete vm=#{vm.uuid} reason=#{err}"

    next null

  destroyNode = (next, results) ->
    Provider.for_server req.params.node_id, (err, provider) ->
      if err
        res.send 500, err

      if provider
        # TODO better way how to pass arguments (see ec2.rb stop)
        options = 
          id: req.params.node_id
          provider: provider

        req = broker.dispatch provider.service, 'stop', options
        req.on 'data', (message) ->
          next null, message

        req.on 'error', (message) ->
          next 
            code: 500
            message: "node destroy failed reason=#{message.reason}"
      else
        next 
          code: 500
          message: "Unknown provider for node '#{req.params.server}'"

  async.auto
    getHostnode: getHostnode
    allVMs: ['getHostnode', allVMs]
    verifyVMs: ['allVMs', verifyVMs]
    destroyVMs: ['verifyVMs', destroyVMs]
    destroyNode: ['destroyVMs', destroyNode]
  , (err, results) ->
    if err
      return res.send err.code, err.message

    res.send 201, "ok"

# TODO move to appropriate module (servers)
module.exports.notify = (req, res, next) ->
  data = JSON.parse(req.body)
  # FIXME verify data/action
  Hostnode.find_by_server_id req.params.node_id, (err, node) ->
    if node
      # FIXME process body to find action
      node.fire data["action"], data.node , (err) -> 
        if err
          console.log(err)

      res.send 200
    else
      log.error("Notification for invalid hostnode=#{req.params.node_id}")
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
