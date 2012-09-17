#
# VM Bootstrap Workflow
#

log = require("log4js").getLogger()

bootstrap_vm = (helper, data, next) ->
  helper.post "/vms/#{data.vm.uuid}/bootstrap", {}, (err, req, res, obj) ->
    if err
      next obj

    next null, data

wait_for_vm = (helper, data, next) ->
  vm_uuid = "vm:#{data.vm.uuid}"

  next null, data,
    type: 'subscribe'
    timeout: 570000
    selector: (object, message, next) ->
      next() if object is vm_uuid and message.event is 'bootstrapped'
    callback: workflow_finish
    on_expiry: on_expiry_bootstrap

workflow_finish = (helper, data, next) ->
  next null, data

on_expiry_bootstrap = (helper, data, next) ->
  next null, data

on_error = (helper, data, next, err) ->
  # FIXME implement
  console.log '-VM_BOOTSTRAP: failed'
  console.log err

  next null, data


class VMBootstrapWorkflow
  constructor: () ->
    return {
      flow: [bootstrap_vm, wait_for_vm]
      on_error: on_error
      timeout: 600000
    }

module.exports = VMBootstrapWorkflow