module.exports = ->

log = require("log4js").getLogger()

module.exports.processDependencies = (vm_list) ->
	# sort list by number of dependencies
	by_dependency_count = (a, b) ->
		a.dependencies.length - b.dependencies.length

	sorted_vms = vm_list.sort(by_dependency_count)

	# expand dependency list
	for vm in sorted_vms
		dependencies = vm.dependencies

		vm.dependencies = []
		for dep in dependencies
			unless dep.component is 'vm'
				log.warn "vm=#{vm.uuid} invalid dependency component=#{dep.component}"
			else
				vm_dep = findVm(dep.name, vm_list)
				vm.dependencies.push(vm_dep)

	console.log 'xx'
	console.log sorted_vms

	# resolve dependencies
	dependencyList = []
	for vm in sorted_vms
		resolveDependencies(vm, dependencyList)

	console.log '--'
	console.log dependencyList

findVm = (vm_name, vm_list) ->
	for vm in vm_list
		return vm if vm.name == vm_name

	return null

resolveDependencies = (vm, output, processed = []) ->
	processed.push(vm)

	for dep in vm.dependencies
		if output.indexOf(dep) == -1
				if processed.indexOf(dep) >= 0
					throw 'Circular reference detected!'

				resolveDependencies(dep, output, processed)

	output.push(vm) unless output.indexOf(vm) >= 0

	pos = processed.indexOf(vm)
	processed.splice(pos, 1, ) if pos >= 0

