#!/usr/bin/env ruby

class Node
	attr_accessor :name, :edges

	def initialize(name)
		@name = name
		@edges = []
	end

	def add(node)
		@edges << node
	end

	def del(node)
		@edges.delete(node)
	end

	def dependencies_count
		count = 0
		@edges.select {|e| count = e.dependencies_count + 1}
		
		count
	end
end

def resolve_dependecies(node, output, processed = [])
	processed << node

	node.edges.each do |edge|
		if !output.include?(edge)
			if processed.include?(edge)
				raise "Circular reference!" if !output.include?(edge) && processed.include?(edge)
			end

			resolve_dependecies(edge, output, processed)
		end
	end

	output << node unless output.include?(node)
	processed.delete(node)
end

def get_batch(node_list)
	batch = []

	node_list.each do |node|
		if node.dependencies_count == 0
			batch << node
		else 
			break
		end
	end

	batch
end

def remove_node(node, node_list)
	node_list.delete(node)

	node_list.each do |a_node|
		a_node.del(node)
	end
end

a = Node.new('a')
b = Node.new('b')
c = Node.new('c')
d = Node.new('d')

#c.add()
a.add(b)
b.add(c)
d.add(c)

result = []

process = [a,b,c,d]
process.sort_by! {|o| o.dependencies_count}

process.each do |node|
	resolve_dependecies(node, result)
end

#----

puts 'pre-run list'
result.each do |node|
	puts "#{node.name} - #{node.edges.inspect}" 
end

until result.count == 0
	batch = get_batch(result)

	puts '-- batch ---'

	batch.each do |node|
		puts node.name

		remove_node(node, result)
	end
end
