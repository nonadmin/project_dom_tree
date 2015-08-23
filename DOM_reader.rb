# DOM_reader takes the idea of the tag parser and scales it up to the entire HTML
# document.  We break down each HTML element using one regex and store that as a
# node.  We then search through the "data" of that element to determine if it has
# any children, and so on until the entire document has been parsed into a tree.

require_relative 'tag_parser.rb'

Node = Struct.new(:name, :text, :classes, :id, :children, :parent, :raw_data, 
                  :raw_child_tags)

class DOMReader
  include TagParser

  attr_reader :root

  def initialize(html_file)
    # The root is the html element and its raw_data is the entire document 
    # except doctype and the html opening and closing tags
    raw_html = File.read(html_file)
    @root = Node.new
    @root.name = :html
    trimmed_html = get_instance_of_tag("html", raw_html)
    @root.raw_data = trimmed_html[1]
  end


  def build_tree
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
        tag = get_first_tag(raw_tag)
        # get the tag attributes
        child_attr = parse_tag(tag)
        # create a new node and setup attributes
        child = Node.new
        child.name = child_attr[:name]
        child.id = child_attr[:id]
        child.classes = child_attr[:classes]

        child.parent = node

        # now we setup the child's raw data
        raw_data = get_instance_of_tag(child.name.to_s, raw_tag)
        child.raw_data = raw_data[1]

        node.children << child
        queue << child
      end

      #raw_child_tags is no longer needed once all the children have been built
      node.raw_child_tags.clear

    end
   
  end
  

end