mongoose = require("mongoose")
LabDefinition = mongoose.model('LabDefinition')

seed_lab = ->
  config = {
    name: 'win_lab',
    token: 'MawNb8dPgHqwz9eoUVsotDAAMauNjJeh',
    version: "0.1.0",
    use: "TenxLabs::ChefProvider",
    repo: "git://github.com/10xEngineer/wip-lab-definition.git"
    metadata: {    
      maintainer: "John Doe",
      maintainer_email: "john@example.xxx",
      long_description: "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec varius rutrum lectus, at laoreet felis feugiat at. Nam sed ligula nec libero condimentum iaculis."
    },
    vms: [
      {vm_name: 'winserv', vm_type: 'win2008r2', hostname: 'webserv.local', run_list: [], vm_attrs: {}},
    ]
  }

  win_lab = new LabDefinition(config)
  win_lab.save (err) ->
    if err
      console.log "Unable to create lab: #{err}"
  

module.exports.seed = seed_lab
