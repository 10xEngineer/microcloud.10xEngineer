module.export = ->

dataStructures = module.export =
	node: (data) ->
		@data = data
		@previous = null
		@next = null

	linkedList: ->
		first = null
		last = null
		@getFirst = ->
			first

		@getLast = ->
			last

		@insertFirst = (value) ->
			newNode = new dataStructures.node(value)
			if first is null
				last = newNode
			else
				first.previous = newNode
				newNode.next = first
			first = newNode

		@insertLast = (value) ->
			newNode = new dataStructures.node(value)
			if last is null
				first = newNode
			else
				last.next = newNode
				newNode.previous = last
			last = newNode

		@deleteFirst = ->
			if first is null
				false
			else
				if first.next is null
					last = null
				else
					first.next.previous = null
				first = first.next
				true

		@deleteLast = ->
			if last is null
				false
			else
				if first.next is null
					first = null
				else
					last.previous.next = null
				last = last.previous
				true

		@insertAfter = (key, value) ->
			return false  if first is null
			current = first
			while current.data isnt key
				current = current.next
				return false  if current is null
			newNode = new dataStructures.node(value)
			if current is last
				newNode.next = null
				last = newNode
			else
				newNode.next = current.next
				current.next.previous = newNode
			newNode.previous = current
			current.next = newNode
			true

		@deleteKey = (key) ->
			return false  if first is null
			current = first
			while current.data isnt key
				current = current.next
				return false  if current is null
			if current is first
				first = current.next
			else
				current.previous.next = current.next
			if current is last
				last = current.previous
			else
				current.next.previous = current.previous
			true

		@traverseForwards = (callback) ->
			current = first
			while current
				callback current
				current = current.next

		@traverseBackwards = (callback) ->
			current = last
			while current
				callback current
				current = current.previous

	stack: ->
		elements = undefined
		@push = (element) ->
			elements = []  if typeof (elements) is "undefined"
			elements.push element

		@pop = ->
			elements.pop()

		@stackTop = (element) ->
			elements[elements.length - 1]

	queue: ->
		elements = undefined
		@enqueue = (element) ->
			elements = []  if typeof (elements) is "undefined"
			elements.push element

		@dequeue = ->
			elements.shift()

		@peek = ->
			elements[0]
