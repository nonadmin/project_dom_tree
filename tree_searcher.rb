class TreeSearcher

  def initialize(tree)
    @tree = tree
  end


  def search_by(attribute, search_term, search_from = @tree, search_direction = :children)
    # by default we start searching from the root (@tree)
    queue = [search_from]
    result = []

    until queue.empty?

      current_node = queue.shift

      # handling regex as a search_term
      if !current_node.send(attribute).nil? && search_term.is_a?(Regexp) 
        node_attribute_data = []
        node_attribute_data << current_node.send(attribute)
          if node_attribute_data.flatten.join(" ").match(search_term)
            result << current_node
          end 

      # regular search term
      elsif !current_node.send(attribute).nil? &&
            current_node.send(attribute).include?(search_term)
        result << current_node 
      end

      # search direction handling
      if search_direction == :children
        queue += current_node.children unless current_node.children.nil?
      elsif search_direction == :parents
        queue << current_node.parent unless current_node.parent.nil?
      end

    end

    result
  end


  def search_descendents(node, attribute, search_term)
    search_by(attribute, search_term, node)
  end


  def search_ancestors(node, attribute, search_term)
    search_by(attribute, search_term, node, :parents)
  end
  
  
end