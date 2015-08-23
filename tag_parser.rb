module TagParser

  def parse_tag(string)
    tag_data = {}
    tag_data[:name] = get_tag_name(string)

    attributes = get_attributes(string)
    attributes.each do |attr|
      name = get_attribute_name(attr)

      if name == "id" || name == "class"
        values = get_attribute_values(attr)
        tag_data[name.to_sym] = values
      end 

    end
    
    tag_data[:classes] = tag_data.delete(:class) if tag_data.has_key?(:class)
    tag_data
  end


  def get_tag_name(string)
    name = string.match(/(?<=<)[^\s|>]*/)
    name.to_s
  end


  def get_attributes(string)
    string.scan(/\w*[=\s]+['|"][\w\s]+['|"]/)
  end


  def get_attribute_name(string)
    name = string.match(/^\w.*?(?=\s|=)/)
    name.to_s  
  end


  def get_attribute_values(string)
    values = string.match(/['|"](.*?)['|"]/)
    values = values.captures[0].split(" ")
    if values.length == 1
      return values[0]
    else
      return values
    end
  end


  def get_first_tag(text)
    # regex <\s*\w.*?> to return all start tags in text
    # get_tag_name(result[0])
    all_tags = text.scan(/<\s*\w.*?>/)
    all_tags[0]  
  end


  # returns the first instance of a tag, the match result is the tag and
  # everything it contains, the match group (match[1]) is just the contents of
  # the tag
  def get_instance_of_tag(tag, search_text)
    # issues come up with greedy vs non-greedy regex when running this search
    # and you need to determine if you're dealing with a tag that has siblings
    # (<li></li><li></li>) or nested children (<div><div></div></div>) of the same
    # element name, for now, will fail with nested children
    consecutive_regex = /<\s*#{tag}[^>]*>(.*?)<\s*\/\s*#{tag}>/m
    #nested_regex = /<\s*#{tag}[^>]*>(.*)<\s*\/\s*#{tag}>/m
    search_text.match(consecutive_regex)
  end


  def seperate_text_from_tags(node)
    node.raw_child_tags = []
    # while theres still tags in the nodes raw_data
    while raw_tag = get_first_tag(node.raw_data)
      # get the name of the search tag
      search_tag = get_tag_name(raw_tag)
      # find all instances of the tag, including attributes and data
      tag = get_instance_of_tag(search_tag, node.raw_data)
      # delete the tag from the raw_data and
      # move it to raw_tags array for further processing
      node.raw_child_tags << node.raw_data.slice!(tag[0])
    end

    # now all tags have been removed from raw_data
    # leaving only non-HTML text contained in the node

    # set the node's text to the remaining raw_data
    node.text = node.raw_data.dup
    # clean up the text, remove extra white space, new lines
    node.text.gsub!(/\s+/, " ")
    node.text.strip!

    # clear the raw data so we know the node's ready for the next step
    node.raw_data = nil
  end

end