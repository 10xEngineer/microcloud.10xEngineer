# Providers

Used to track connection/environment details for infrastructure providers. Custom data might include credentials, environment definition, etc.

Object type

      name: String (user identification)
      service: String (broker service to use)
      data: [{Object}] (Custom data passed to service)

Sample message

      {
        name: "vagrant1",
        service: "vagrant",
        data: [{
          env: "/path/to/vagrant/file/to/use"
        }]
      }

URL namespace

* `GET /providers` - list of available providers
* `POST /providers` - create new provider (JSON message)
* `GET /providers/:provider` - display provider
* `DELETE /providers/:provider` - delete provider

## Seed data

You can seed data store (Mongo) using `seed.coffee` which reads files from `server/db/`. Sample provider (EC2 in this case) looks like this

mongoose = require("mongoose")
    Provider = mongoose.model('Provider')

    ec2 = ->
      config = {
        name: 'ec2-acc1',
        service: 'ec2',
        data: {
          access_key_id: "...hah...",
          secret_access_key: ".......won't tell...........",
          region: "eu-west-1",
          key: "europe-default",
          ami: "ami-55393c21"
        }
      }

      ec2_provider = new Provider(config)
      ec2_provider.save (err) ->
        if err
          console.log "Unable to create ec2 provider: #{err}"

    module.exports.seed = ec2
      

