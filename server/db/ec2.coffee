mongoose = require("mongoose")
Provider = mongoose.model('Provider')

ec2 = ->
  config = {
    name: 'ec2',
    service: 'ec2',
    handler: 'lxc',
    data: {
      access_key_id: "AKIAJIPBWGE6PG5C2VGA",
      secret_access_key: "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",
      region: "eu-west-1",
      key: "europe-default",
      ami: "ami-77f0f503"
    }
  }

  ec2_provider = new Provider(config)
  ec2_provider.save (err) ->
    if err
      console.log "Unable to create ec2 provider: #{err}"

module.exports.seed = ec2
  
