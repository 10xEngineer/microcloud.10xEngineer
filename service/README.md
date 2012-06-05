# Service Broker

Before running service broekr, you need prepare service broker default configuration

    cp Procfile.sample Procfile
    bundle
    
To run the broker and services (defined within Procfile) use

    bundle exec foreman start

Or you can specific services on command line (together with number of instances to run)

    bundle exec foreman start -c "broker=1, demo_service=2"

which will start single instance of broker and 2 instance of DemoService. You can also specify all options to `.foreman` file in current folder. For more information, please, consult [Foreman man page](http://ddollar.github.com/foreman/)

## Sample messages

dummy::ping

    -> {"service":"dummy","action":"ping","options":{"say":"Hi!"}}
    <- {"status":"ok","options":{"reply":"go tiger!"}}

vagrant::status

    -> {"service":"vagrant","action":"status","options":{"env":"/path/to/vangrant/env"}}
    <- {"status":"ok","options":{"state":"poweroff"}}

For Ruby client implementation see `test_command.rb`. 

## Service Providers

All services are started using `service.rb` wrapper which providers shared logic. The providers are defined within `./providers/`.

## Services

* dummy - user for development and testing
* vagrant - vagrant server provisioner
* ec2 - ec2 provisioner
* lcx - linux container manager servicer

## Message format

Request message format as recognized by broker. 

     {
        "service": "service_name",
        "action": "action_name",
        "options": {
            ...
        }
     }

where

* **service** where to send the message, in future should be dropped in favour of dynamic routing and service discovery
* **action** to trigger
* **options** to pass to the actions (parameters, environment setup, etc).

## Known limitations

* static service configuration, you can't add new service without broker restart
* API is exposed to service details (service name)
* no pool/activity monitoring
* multiple endpoints (tcp/ipc) and configuration support
