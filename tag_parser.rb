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

    tag_data[:id] = tag_data[:id].join if tag_data[:id]
    tag_data[:classes] = tag_data.delete(:class) if tag_data.has_key?(:class)
    tag_data
  end


  def get_tag_name(string)
    name = string.match(/(?<=<)[^\s|>]*/)
    name.to_s
  end


  def get_attributes(string)
    string.scan(/\w*[=\s]+['|"][\w\s-]+['|"]/)
  end


  def get_attribute_name(string)
    name = string.match(/^\w.*?(?=\s|=)/)
    name.to_s  
  end


  def get_attribute_values(string)
    values = string.match(/['|"](.*?)['|"]/)
    values = values.captures[0].split(" ")
  end


  def get_all_opening_tags(raw_data)
    # regex <\s*\w.*?> to return all start tags in text
    raw_data.scan(/<\s*\w.*?>/) 
  end


  # this method determines if the first two tags in our raw_data have the same name
  def same_tags_at_start_of_data?(raw_data)
    raw_tags = get_all_opening_tags(raw_data)
    first_tag = get_tag_name(raw_tags[0])
    # stops error when there's only one tag left in the raw_data
    second_tag = raw_tags[1].nil? ? nil : get_tag_name(raw_tags[1])  
    first_tag == second_tag
  end


  # we know we're dealing with nested tags of the same name if another opening
  # tag appears before the first closing tag.  this method looks at the results
  # of scanning the raw_data for opening and closing tags and seeing if the 
  # second match of the opening tag appears before the first match of the closing
  # tag
  def nested_same_tag?(tag, raw_data)
    opening_regex = /<\s*#{tag}.*?>/
    closing_regex = /<\s*\/\s*#{tag}\s*.*?>/
    # the method chain here is sort of a cludge to get all the MatchData objects
    # so that we can use the begin method to check where they appear in raw_data
    # since normally match would return just the first, and last_match the last.
    opening_tags = raw_data.to_enum(:scan, opening_regex).map { Regexp.last_match }
    closing_tags = raw_data.to_enum(:scan, closing_regex).map { Regexp.last_match }
    opening_tags[1].begin(0) < closing_tags[0].begin(0)
  end


  # returns the first instance of a tag, the match result is the tag and
  # everything it contains, the match group (match[1]) is just the contents of
  # the tag
  def get_instance_of_tag(tag, raw_data, nested_tags = false)
    # issues come up with greedy vs non-greedy regex when running this search
    # and you need to determine if you're dealing with a tag that has siblings
    # (<li></li><li></li>) or nested children (<div><div></div></div>) of the same
    # element name, for now, will fail with nested children
    consecutive_regex = /<\s*#{tag}[^>]*>(.*?)<\s*\/\s*#{tag}>/m
    nested_regex = /<\s*#{tag}[^>]*>(.*)<\s*\/\s*#{tag}>/m
    if nested_tags
      raw_data.match(nested_regex)
    else
      raw_data.match(consecutive_regex)
    end
  end


  def seperate_text_from_tags(node)
    node.raw_child_tags = []
    # loop until there's no tags left in our raw data
    until ( raw_tags = get_all_opening_tags(node.raw_data) ).empty?
      # get the name of first/top tag for the search
      search_tag = get_tag_name(raw_tags[0])
      # determine if we're dealing with consecutive tags of the same name
      # at the start of our data, if so this changes our "chunking" search
      # based on if these tags are siblings or nested
      if same_tags_at_start_of_data?(node.raw_data) &&
         nested_same_tag?(search_tag, node.raw_data)
        # find first instance of the tag, including attributes and data
        tag = get_instance_of_tag(search_tag, node.raw_data, true)
      else
        tag = get_instance_of_tag(search_tag, node.raw_data)
      end

      # copy to raw_child_tags array for further processing
      node.raw_child_tags << tag[0]

      # leave a reference to the child so that if there's any text
      # we can re-insert the child correctly if rebuilding or rendering
      child_number = node.raw_child_tags.length
      node.raw_data.gsub!(tag[0], "child_tag_#{child_number}")
    end

    # now all tags have been removed from raw_data
    # leaving only non-HTML text contained in the node

    # set the node's text to the remaining raw_data
    node.data = node.raw_data.dup
    # clean up the text, remove extra white space, new lines
    node.data.gsub!(/\s+/, " ")
    node.data.strip!

    # clear the raw data, its no longer needed
    node.raw_data = nil
  end

end