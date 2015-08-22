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

end