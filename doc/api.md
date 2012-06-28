# Microcloud API

TODO

## RESTful approach

All resources should be exposted in format

    /plural-resource-name/:resource_id

for example

    /nodes/:node_id

and implementing basic CRUD logic. Microcloud notifications for resources should be exposted as

    /plural-resource-name/:resource_id/notify

with the request body

    {
      action: event-to-trigger,
      resource-name: {
        # custom data
      }
    }
