mongoose = require("mongoose")
LabDefinition = mongoose.model('LabDefinition')

seed_lab = ->
  config = {
    name: 'win_lab',
    token: 'MawNb8dPgHqwz9eoUVsotDAAMauNjJeh',
    vms: [
      {vm_name: 'winserv', vm_type: 'win2008r2', hostname: 'webserv.local', run_list: [], vm_attrs: {}},
    ]
  }

  win_lab = new LabDefinition(config)
  win_lab.save (err) ->
    if err
      console.log "Unable to create lab: #{err}"
  

module.exports.seed = seed_lab
