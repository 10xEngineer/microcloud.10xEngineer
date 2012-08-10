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

# wait for VM to get allocated (analogy to `knife bootstrap`)
wait_for_vm = (helper, data, next) ->

  vm_uuid = "vm:#{data.vm.uuid}"

  next null, data,
    type: 'subscribe'
    timeout: 60000
    selector: (object, message, next) ->
      next() if object is vm_uuid
    callback: do_something
    on_expiry: on_expiry_allocate

do_something = (helper, data, next) ->
  console.log '---- VM allocate finished'

  next null, data

on_expiry_allocate = (helper, data, next) ->
  console.log '---- VM allocate expired'

  next null, data

on_error = (helper, data, next, err) ->
  # FIXME implement
  console.log '-VM_ALLOCATE: failed'
  console.log err

class VMAllocateWorkflow
  constructor: () ->
    return {
      flow: [lock_vm, wait_for_vm]
      on_error: on_error
      timeout: 120000
    }

module.exports = VMAllocateWorkflow