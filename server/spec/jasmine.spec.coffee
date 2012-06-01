describe "Allocation and Deallocation", ->
	Pool = require("../utility/ServerPool.js")
	
	it "Allocation", ->
		pool = new Pool("local", 3, 5)

		container1 = pool.allocate 2, "anderson", "session1"
		container2 = pool.allocate 2, "anderson", "session1"
		container3 = pool.allocate 3, "anderson", "session1"
		container4 = pool.allocate 2, "anderson", "session1"
		container5 = pool.allocate 2, "anderson", "session1"
		container6 = pool.allocate 3, "anderson", "session1"
		container7 = pool.allocate 3, "anderson", "session1"

		expect(container1.length).toBe(2)
		expect(container2.length).toBe(2)
		expect(container3.length).toBe(3)
		expect(container4.length).toBe(2)
		expect(container5.length).toBe(2)
		expect(container6.length).toBe(3)
		expect(container7.length).toBe(0)

	it "Deallocation", ->
		pool = new Pool("local", 3, 5)

		container1 = pool.allocate 2, "anderson", "session1"
		container2 = pool.allocate 2, "anderson", "session1"
		container3 = pool.allocate 3, "anderson", "session1"
		container4 = pool.allocate 2, "anderson", "session1"
		container5 = pool.allocate 2, "anderson", "session1"
		container6 = pool.allocate 3, "anderson", "session1"
		container7 = pool.allocate 3, "anderson", "session1"

		pool.deallocate container1
		pool.deallocate container2

		container8 = pool.allocate 5, "anderson", "session1"
		expect(container8.length).toBe(5)

		container9 = pool.allocate 1, "anderson", "session1"
		expect(container9.length).toBe(0)

		pool.deallocate container8[4]
		pool.deallocate container8[2]
		pool.deallocate container8[0]

		container10 = pool.allocate 3, "anderson", "session1"
		expect(container10.length).toBe(3)