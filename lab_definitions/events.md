# Microcloud Events 

Sources

* 10xLab native objects (VM, Components, Pools)
* Chef Resources
* Other services (via adapters)

## Chef Resources events

Implemented via Report/Exception handlers (Chef specific). Run status provides information on

* `all_resources` collected during Chef run
* `updated_resources` collection as source of event (TODO need to find out how granular updates we can get)

## Other services

API driven libraries for custom development (ie. customers' control panels, enhanced provisioning logic, etc.). Generally used as a way to extend 10xLabs. Should have option to subscribe for events even outside 10xlab environment (some sort of messaging queue).

# Event listener

Native components can register event callback

		on "object_name::event_name", callback

where wildcard (*), or regex can be used to match individual names. 

**TODO** re-usable handlers via ruby style mixins? Ie. `include SomeCleverMonitoring`. Might involve other aspects (other than listeners).

Object receives notifications only if specified implicitly via `depends_on` relation, or introspection.

**TODO** is subscription unidirectional or do we need bidirectional? How to describe it?

# Introspection

Allows objects to register for notifications, enumerate objects based on 10xLab internal inventory. 

**TODO** introspection spec
**TODO** OS/system level sources (ie. how to expose individual chef resources)

# Events

Node.js style `emit`. 

**TODO**

# Sample use cases 

VM Starts -> register DNS hostname

VM Fails (source monitoring) -> replace VM, autoscaling, escalate alert, etc.

Component AcmeApp upgrades code (GIT hook) -> needs to notify acme_db to run migration -> which needs to notify app to start again.

# Chef level notification

**TODO** Custom 

