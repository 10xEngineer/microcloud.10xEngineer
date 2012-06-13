mongoose = require("mongoose")
Provider = mongoose.model('Provider')

ec2 = ->
  config = {
    access_key_id: "xxxxx",
    secret_access_key: "xxxxxxxxx",
    region: "us-east-1",
    key: "ec2-keypair",
    ami: "ami-3202f25b"
  }

  ec2_provider = new Provider(config)
  ec2_provider.save (err) ->
    if err
      console.log "Unable to create ec2 provider: #{err}"

module.exports.seed = ec2
  
