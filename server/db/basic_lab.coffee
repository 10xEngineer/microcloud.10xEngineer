mongoose = require("mongoose")
LabDefinition = mongoose.model('LabDefinition')

seed_lab = ->
  config = {
    name: 'basic_lab',
    token: 'zcnLcnrCTWMBvhGPzn9srGe9HGCMtnyD',
    vms: [
      {vm_name: 'webserv', vm_type: 'ubuntu', hostname: 'webserv.local', run_list: [], vm_attrs: {}},
      {vm_name: 'dbserv', vm_type: 'ubuntu', hostname: 'db.local', run_list: [], vm_attrs: {}}
    ]
  }

  basic_lab = new LabDefinition(config)
  basic_lab.save (err) ->
    if err
      console.log "Unable to create lab: #{err}"
  

module.exports.seed = seed_lab
