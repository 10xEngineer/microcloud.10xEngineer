define ->
	sp.Class.create "AllocationPool",
		constructor: AllocationPool = (klass, maxSize) ->
			@klass = klass
			@maxSize = maxSize or 100
			@pool = []

		properties:
			klass: null
			maxSize: 100
			pool: null

		methods:
			borrowItem: borrowItem = ->
				if @pool.length > 0
					@pool.pop()
				else
					new @klass()

			recycle: recycle = (item) ->
				@pool.push item  if @pool.length < @maxSize
