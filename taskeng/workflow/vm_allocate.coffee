#
# VM Allocate Workflow
#

log = require("log4js").getLogger()

allocate_vm = (helper, data, next) ->
  # FIXME resolve pol
  pool_name = data.vm.pool || data.lab.pools.compute.name

  bootstrap_data = 
    lab: data.lab.name
    vm: data.vm

  helper.post "/pools/#{pool_name}/allocate", bootstrap_data, (err, req, res, obj) ->
    if err
      next obj

    data.vm.uuid = obj.uuid

    next null, data

on_error = (helper, data, next, err) ->
  # FIXME implement
  console.log '-VM_ALLOCATE: failed'
  console.log err

  next null, data

class VMAllocateWorkflow
  constructor: () ->
    return {
      # TODO insert start (depends on server handler type)
      flow: [allocate_vm]
      on_error: on_error
      timeout: 60000
    }

module.exports = VMAllocateWorkflow