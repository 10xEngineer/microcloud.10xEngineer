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
  # TODO implement
  res.send {}

module.exports.updates = (req, res, next) ->
  data = JSON.parse req.body

  Vm
    .findOne({uuid: req.params.vm})
    .populate("lab")
    .exec (err, vm) ->
      if vm
        vm.fire data.action, {}, (err) ->
          if err
            console.log err

        res.send 200
      else
        log.error("Notification for invalid vm=#{req.params.vm}")
        res.send 404, {}

module.exports.create = (req, res, next) ->
  # TODO support for multiple VM provisioning (?count=N)
  Hostnode.findOne {server_id: req.params.server_id}, (err,hostnode) ->
    data = {
      server: hostnode.hostname
    }

    broker.dispatch 'lxc', 'prepare', data, (message) ->
      if message.status == 'ok'
        vm_data = {
          uuid: message.options.id,
          state: message.options.state,
          pool: message.options.pool,
          vm_type: message.options.type,
          server: req.params.server_id,
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

            res.send vm
      else
        console.log "#{hostnode.hostname}: Unable to prepare VM(#{message.options.reason})"
        res.send 500, "failed: #{message.options.reason}"

# TODO start
# TODO stop

# TODO extended functionality (VM migration/hibernation/etc)
