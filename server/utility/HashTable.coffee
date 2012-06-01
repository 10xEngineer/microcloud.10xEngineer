class HashTable
	constructor: ->
		@length = 0
		@items = {}

	size: ->
		return @length

	setItem : (key, value) ->
		previous = null
		if @hasItem(key)
			previous = @items[key]
		else
			@length++
		@items[key] = value
		return previous

	getItem : (key) ->
		(if @hasItem(key) then @items[key] else null)

	hasItem : (key) ->
		@items.hasOwnProperty key

	removeItem : (key) ->
		if @hasItem(key)
			previous = @items[key]
			@length--
			delete @items[key]

			previous
		else
			null

	keys : ->
		keys = []
		for k of @items
			keys.push k  if @hasItem(k)
		keys

	values : ->
		values = []
		for k of @items
			values.push @items[k]  if @hasItem(k)
		values

	each : (fn) ->
		for k of @items
			fn k, @items[k]  if @hasItem(k)

	clear : ->
		@items = {}
		@length = 0

module.exports = HashTable