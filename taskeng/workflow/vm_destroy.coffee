#
# VM Destroy Workflow
#

log = require("log4js").getLogger()

destroy_vm = (helper, data, next) ->
  helper.delete "/vms/#{data.vm.uuid}", (err, req, res) ->
    if err
      return next err

    next null, data 

finish = (helper, data, next) ->
  log.info "YY destroy_vm finished"

  next null, data

on_error = (helper, data, next, err) ->
  log.error "workflow=vm_destroy failed reason=#{err}"
  
  next null, data

class VMDestroyWorkflow
  constructor: () ->
    return {
      flow: [destroy_vm, finish]
      on_error: on_error
      timeout: 60000
    }

module.exports = VMDestroyWorkflow