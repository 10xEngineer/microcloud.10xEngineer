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
