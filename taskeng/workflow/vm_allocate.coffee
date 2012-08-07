#
# VM Allocate Workflow
#

log = require("log4js").getLogger()

lock_vm = (helper, data, next) ->
  pool_name = data.vm.pool || data.lab.pool

  allocate_data = 
    lab: data.lab.name
    vm: 
      vm_name: data.vm.name

  helper.post "/pools/#{pool_name}/allocate", allocate_data, (err, req, res, obj) ->
    if err
      next res
      
    data.vm.uuid = obj.uuid

    next null, data

allocate_vm = (helper, data, next) ->
  # TODO how to get provider for VM's hostnode?




on_error = (helper, data, next, err) ->
  # FIXME implement
  console.log '-VM_ALLOCATE: failed'
  console.log err

class VMAllocateWorkflow
  constructor: () ->
    return {
      flow: [lock_vm]
      on_error: on_error
      timeout: 60000
    }
