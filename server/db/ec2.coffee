mongoose = require("mongoose")
Provider = mongoose.model('Provider')

ec2 = ->
  config = {
    name: 'ec2',
    service: 'ec2',
    handler: 'lxc',
    data: {
      access_key_id: "AKIAJP7XP2CXAAVP3VHA",
      secret_access_key: "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",
      region: "eu-west-1",
      key: "radim-eu",
      ami: "ami-19eeea6d",
      security_group: "tenxlab_node"
    }
  }

  ec2_provider = new Provider(config)
  ec2_provider.markModified("data")
  ec2_provider.save (err) ->
    if err
      console.log "Unable to create ec2 provider: #{err}"

module.exports.seed = ec2
  
