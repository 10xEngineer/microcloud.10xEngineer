mongoose = require("mongoose")
Provider = mongoose.model('Provider')

ec2_win = ->
  config = {
    name: 'ec2-win',
    service: 'ec2',
    handler: 'loop',
    data: {
      access_key_id: "AKIAJIPBWGE6PG5C2VGA",
      secret_access_key: "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",
      region: "eu-west-1",
      key: "europe-default",
      ami: "ami-cf2226bb",
      security_group: "windows-default"
    }
  }

  ec2_provider = new Provider(config)
  ec2_provider.save (err) ->
    if err
      console.log "Unable to create ec2 provider: #{err}"

module.exports.seed = ec2_win
  

