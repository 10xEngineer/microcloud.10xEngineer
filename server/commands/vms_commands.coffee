module.exports = ->

mongoose = require("mongoose")
log = require("log4js").getLogger()
broker = require("../broker")
Vm = mongoose.model('Vm')
Hostnode = mongoose.model('Hostnode')


#
# VM commands
#

module.exports.index = (req, res, next) ->
  Hostnode.findOne({server_id: req.params.node_id}).exec (err,hostnode) ->
    if hostnode
      Vm
        .find({server: hostnode})
        .fields({"uuid": 1, "state": 1})
        .exec (err, vms) ->
          res.send vms
    else
      res.send 404, "No hostnode=#{req.params.node_id} found"

module.exports.get = (req, res, next) ->
  # TODO use decorators
  #      https://trello.com/card/api-objects-decorators/50067c2712a969ae032917f4/39
  Vm
    .findOne({uuid: req.params.vm})
    .exec (err, vm) ->  
      if vm
        res.send vm
      else res.send 404, err || "VM not found"

module.exports.updates = (req, res, next) ->
  data = JSON.parse req.body
  Vm
    .findOne({uuid: req.params.vm})
    .populate("lab")
    .populate("server")
    .exec (err, vm) ->
      if vm
        vm.fire data.action, data.vm, (err) ->
          if err
            console.log err

        res.send 200
      else
        log.error("Notification for invalid vm=#{req.params.vm}")
        res.send 404, {}

module.exports.create = (req, res, next) ->
  try
    options = JSON.parse req.body
  catch e
    options = {}
  # FIXME check for hostnode in 'new' state (not yet ready)
  # TODO support for multiple VM provisioning (?count=N)
  Hostnode.findOne({server_id: req.params.node_id}).populate("pool").exec (err,hostnode) ->
    unless hostnode
      res.send 404, "failed: specified hostnode not found"
    else
      data = {
        server: hostnode.hostname
        pool: hostnode.pool._id
      }
      # TODO
      # options.pool not recognized
      req = broker.dispatch hostnode.type, 'prepare', data
      req.on 'data', (message) ->
        vm_data = {
          uuid: message.options.uuid,
          state: message.options.state,
          pool: message.options.pool,
          vm_type: message.options.type,
          server: hostnode,
          descriptor: {
            storage: message.options.descriptor.fs.size
          }
        }
        vm = new Vm(vm_data)
        vm.save (err) ->
          if err
            log.error "Unable to save VM state: #{err}"

            res.send 409, err.message
          else
            log.info "vm=#{vm_data.uuid} saved"

            # FIXME-events vm :create event notification
            Vm.findById(vm._id).populate('server').exec (err, vm) ->
              if err 
                res.send 500, "failed: #{err.message}"
              else
                res.send vm
      req.on 'error', (message) ->
          log.error "#{hostnode.hostname}: Unable to prepare VM(#{message.options.reason})"
          res.send 500, "failed: #{message.options.source}: #{message.options.reason}"

module.exports.allocate = (req, res, next) ->


module.exports.destroy = (req, res, next) ->
  Vm
    .findOne({uuid: req.params.vm})
    .populate("lab")
    .populate("server")
    .exec (err, vm) ->
      if vm
        options = 
          id: req.params.vm
          server: vm.server.hostname

        req = broker.dispatch vm.server.type, 'destroy', options
        req.on 'data', (message) ->
          vm.fire 'destroy', data.vm, (err) ->
          if err
            console.log err

          # FIXME-events vm :destroy event notification (what about housekeeping initiated VM destroy? notification?)
          res.send 202
      else
        log.error("Notification for invalid vm=#{req.params.vm}")
        res.send 404, {}


# TODO start
# TODO stop

# TODO extended functionality (VM migration/hibernation/etc)
