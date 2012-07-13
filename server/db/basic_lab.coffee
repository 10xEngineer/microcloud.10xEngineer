mongoose = require("mongoose")
LabDefinition = mongoose.model('LabDefinition')

seed_lab = ->
  config = {
    name: 'basic_lab',
    token: 'zcnLcnrCTWMBvhGPzn9srGe9HGCMtnyD',
    version: "0.1.0",
    use: "TenxLabs::ChefHandler",
    repo: "git://github.com/10xEngineer/wip-lab-definition.git"
    metadata: {
      maintainer: "John Doe",
      maintainer_email: "john@example.xxx",
      long_description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec varius rutrum lectus, at laoreet felis feugiat at. Nam sed ligula nec libero condimentum iaculis."
    },
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
