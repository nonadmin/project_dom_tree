require_relative 'DOM_reader'
require_relative 'tree_searcher'

class NodeRenderer


  def initialize(tree)
    @tree = tree    
  end


  def render(node = @tree)
    stats = get_subnode_stats(node)
 
    print "Element '#{node.name.upcase}'"
    
    if node.classes
      print "; classes: "
      node.classes.each do |c|
        c == node.classes[-1] ? print("#{c}") : print("#{c}, ")
      end
    end

    print "; id: #{node.id}" if node.id
      
    print "; data: '#{node.data}'" if node.data
    
    print "\n"

    puts "Number of child nodes: #{stats[:count]}"
    stats[:types].each do |type, count|
      puts "#{type}: #{count}"
    end

    print "\n"

    
  end


  def get_subnode_stats(node)
    queue = []

    unless node.children.nil?
      node.children.each do |child|
        queue << child
      end
    end
      
    sub_nodes = {:count => 0, :types => {}}
    sub_nodes[:types].default = 0

    until queue.empty?

      current_node = queue.shift

      sub_nodes[:count] += 1
      element = current_node.name.to_sym
      sub_nodes[:types][element] += 1           

      queue += current_node.children

    end

    sub_nodes
    
  end
  
  
end


