Host node provider service broker. To run the default configuration use

    bundle
    bundle exec foreman start

To control number of instances (worker pool size) you can use concurrency, like this

    bundle exec foreman start -c "broker=1, demo_service=2"

which will start single instance of broker and 2 instance of DemoService.

## Service Broker

By default broker listens on unix domain `/tmp/mc.broker`

## Services

* Demo Service - used for development and testing purposes
* Vagrant Service - control local provisioning
* Pool Service - TBD
* LCX Service - TBD

