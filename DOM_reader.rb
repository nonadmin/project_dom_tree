# DOM_reader takes the idea of the tag parser and scales it up to the entire HTML
# document.  We break down each HTML element using one regex and store that as a
# node.  We then search through the "data" of that element to determine if it has
# any children, and so on until the entire document has been parsed into a tree.

# The critical method of the DOM reader/parser is that each node will have 
# "raw data" set by its parent.  This raw data is everything contained within its
# opening and closing tags.  As the tree is built we process this data twice.
# Once to seperate non-HTML text from the child tags of the node.  And then again
# For each child node the data is chunked even smaller, to setup the raw_data
# of the child's children. 

# High Level Pseudocode
# 1. Start with the root node (HTML Tag), build a queue with this node in it
# 2. Loop until Queue Empty
## 3. Shift node off queue
## 4. Seperate the node's non-HTML text (if any) from its children
### 5. For each child, currently just raw HTML
### 6. Get the child's attributes by sending its raw tag to the parser
### 7. Create new node and set attributes (name, id, classes, parent)
### 8. Determine if the raw HTML for the child we're processing is part of a set of 
### consecutive elements with the same name.  If it is we need to prepare the child's
### raw HTML data differently depending on if these elements are nested or consecutive
### (The regex changes from being non-greedy to greedy)
### 9. Add to parent node as child
### 10. Add child to queue 
### 11. Next child
## 12. Clear the raw child tags off the parent
# 13. Loop

require_relative 'tag_parser.rb'

Node = Struct.new(:name, :text, :classes, :id, :children, :parent, :raw_data, 
                  :raw_child_tags)

class DOMReader
  include TagParser


  def setup_root(html_file)
    raw_html = File.read(html_file)
    @root = Node.new
    @root.name = :html
    trimmed_html = get_instance_of_tag("html", raw_html)
    @root.raw_data = trimmed_html[1]
  end


  def build_tree(html_file)

    setup_root(html_file)
    queue = [@root]

    until queue.empty?
      node = queue.shift
      node.children = []

      # nodes will start with raw_data, we need to seperate this out 
      # into raw_child_tags and any non-HTML text the node contains
      # we get to a base case when a node has no children, in this case
      # its raw data will be all non-HTML text and the each loop below 
      # will just be skipped over (raw_child_tags will be empty)
      seperate_text_from_tags(node)

      node.raw_child_tags.each do |raw_tag|
        # we get the first tag of the raw_child, which is the actual
        # child node we're constructing
        tags = get_all_opening_tags(raw_tag)
        # get the tag attributes
        child_attr = parse_tag(tags[0])
        # create a new node and setup attributes
        child = Node.new
        child.name = child_attr[:name]
        child.id = child_attr[:id]
        child.classes = child_attr[:classes]

        child.parent = node

        # now we setup the child's raw data
        if same_tags_at_start_of_data?(raw_tag) &&
           nested_same_tag?(child.name.to_s, raw_tag)
          # dealing with nested and consecutive tags
          raw_data = get_instance_of_tag(child.name.to_s, raw_tag, true)
        else
          raw_data = get_instance_of_tag(child.name.to_s, raw_tag)
        end
        child.raw_data = raw_data[1]

        node.children << child
        queue << child
      end

      #raw_child_tags is no longer needed once all the children have been built
      node.raw_child_tags = nil

    end

    @root
   
  end
  

end