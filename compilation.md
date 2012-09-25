# 10xLabs Compiler Service API

Initial PoC of compiler service API

## Create Sandbox

	POST /sandboxes -d {"comp_kit": "10xeng_java", "source_url": "http://addr", "pub_key": "key"}

Creates a new compilation sandbox

* **comp_kit** name of the compilation kit to use
* **source_url** user fragment to use for syncing (supports unauthenticated HTTP/HTTPs URLs, will add GIT repo support next)
* **pub_key** not used at the moment 

Returns HTTP 201 and ID of created sandbox

## Execute

	POST /sanboxes/:sandbox -d {"cmd": "action", "arg1": "val", "arg2": "val"}

Executes `actions` on the existing `:sandbox`.

* **cmd** compile kit action to execute
* **arg1** _(optional) first action argument
* **arg2** _(optional) second action argument

Return HTTP 200 and streams the output of execute action back.

## Destroy sandbox

	DELETE /sandboxes/:sandbox

Removes specified sandbox. 

Returns HTTP 200 if successful.

## TODOs

* accept compile request -> put it within async.queue to control execution throttle
* cleanup inactive sandboxes (after 30 minutes of inactivity)
* compile node LRU load-balancing