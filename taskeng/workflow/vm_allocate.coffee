#
# VM Allocate Workflow
#

log = require("log4js").getLogger()

bootstrap_vm = (helper, data, next) ->
  pool_name = data.vm.pool || data.lab.pool

  bootstrap_data = 
    lab: data.lab.name
    vm: 
      vm_name: data.vm.name

  helper.post "/pools/#{pool_name}/bootstrap", bootstrap_data, (err, req, res, obj) ->
    if err
      next obj
      
    data.vm.uuid = obj.uuid

    next null, data

# wait for VM to get allocated (analogy to `knife bootstrap`)
wait_for_vm = (helper, data, next) ->

  vm_uuid = "vm:#{data.vm.uuid}"

  next null, data,
    type: 'subscribe'
    timeout: 60000
    selector: (object, message, next) ->
      next() if object is vm_uuid and message.event is 'bootstrapped'
    callback: do_something
    on_expiry: on_expiry_allocate

do_something = (helper, data, next) ->
  console.log '---- VM bootstrap finished'

  next null, data

on_expiry_allocate = (helper, data, next) ->
  console.log '---- VM bootstrap expired'

  next null, data

on_error = (helper, data, next, err) ->
  # FIXME implement
  console.log '-VM_ALLOCATE: failed'
  console.log err

  next null, data

class VMAllocateWorkflow
  constructor: () ->
    return {
      flow: [bootstrap_vm, wait_for_vm]
      on_error: on_error
      timeout: 120000
    }

module.exports = VMAllocateWorkflow