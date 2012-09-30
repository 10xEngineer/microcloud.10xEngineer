module.exports = ->

mongoose = require("mongoose")
log = require("log4js").getLogger()
broker = require("../broker")
Vm = mongoose.model('Vm')
Lab = mongoose.model('Lab')
Hostnode = mongoose.model('Hostnode')
async = require "async"

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

  getVMDefinition = (vms, vm_name) ->
    vm_list = (vm for vm in vms when vm.name == vm_name)

    return vm_list[0]

  compile_vmdata = (lab, vm) ->
    # TODO hardcoded
    term_server_url = "http://#{vm.server.hostname}:9090/"

    vm_def = getVMDefinition lab.current_definition.vms, vm.vm_name

    vm_data =  
      uuid: vm.uuid
      descriptor: vm.descriptor
      type: vm.server.type
      state: vm.state
      run_list: vm_def.run_list
      lab:
          name: lab.name
          repo: lab.repo
          definition:
            version: lab.current_definition.version
          # TODO temporary way how to pass attributes to chef-solo run
          #      going to be replaced in near future
          attributes: lab.attrs
      term_server:
          host: vm.server.hostname
          manage_port: 9001
          client_port: 9090
      vm_name: vm.vm_name
      vm_type: vm.vm_type

    res.send vm_data

  # TODO use decorators
  #      https://trello.com/card/api-objects-decorators/50067c2712a969ae032917f4/39
  Vm
    .findOne({uuid: req.params.vm})
    .populate("server")
    .exec (err, vm) ->  
      if vm
        Lab
          .findOne({_id: vm.lab})
          .populate("current_definition")
          .exec (err, lab) ->
            if lab
              return compile_vmdata lab, vm
            else res.send 500, err || "Invalid VM (no lab definition)"

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
        size: options.size
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

module.exports.bootstrap = (req, res, next) ->
  Vm
    .findOne({uuid: req.params.vm})
    .populate("lab")
    .populate("server")
    .exec (err, vm) ->
      if vm
        if vm.state != 'locked'
          return res.send 412, 
            status: "failed"
            reason: "Unable to bootstrap vm=#{vm.uuid} expected state=locked"

        data = 
          id: vm.uuid
          server: vm.server.hostname

        req = broker.dispatch vm.server.type, 'bootstrap', data
        req.on 'data', (message) ->
          res.send 200, 
            status: "ok"

        req.on 'error', (message) ->
          res.send 500,
            status: "failed"


module.exports.stop = (req, res, next) ->
  Vm
    .findOne({uuid: req.params.vm})
    .populate("lab")
    .populate("server")
    .exec (err, vm) ->
      if vm
        options = 
          id: req.params.vm
          server: vm.server.hostname

        req = broker.dispatch vm.server.type, 'stop', options
        req.on 'data', (message) ->
          vm.fire 'stop', message.options, (err) ->
          if err
            console.log err

          # FIXME-events vm :stopped event notification (what about housekeeping initiated VM destroy? notification?)
          res.send 202
      else
        log.error("invalid vm=#{req.params.vm}")
        res.send 404, {}

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

        # TODO stop VM if running
        async.waterfall [
          (next) -> 
            if vm.state == 'running' || vm.state == 'available'
              req = broker.dispatch vm.server.type, 'stop', options
              req.on 'data', (message) ->
                next null

              req.on 'error', (message) ->
                log.error "vm#destroy failed reason=#{message.options.reason}"

                # TODO ignoring all stop errors
                next null
            else next null
          (next) ->
            req = broker.dispatch vm.server.type, 'destroy', options
            req.on 'data', (message) ->
              vm.fire 'destroy', message.options, (err) ->
              if err
                console.log err

              next null

            req.on 'error', (message) ->
              next message.options.reason
        ], (err) ->
          if err
            log.error "vm=#{vm.uuid} failed reason=#{err}"

            vm.state = 'error'
            vm.save (vm_err) ->
              return res.send 500, err

          else res.send 202
      else
        log.error("invalid vm=#{req.params.vm}")
        res.send 404, {}


# TODO start
# TODO stop

# TODO extended functionality (VM migration/hibernation/etc)
