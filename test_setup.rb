require_relative 'node_renderer'
system 'clear'

# sample code
d = DOMReader.new
tree = d.build_tree('test.html');
searcher = TreeSearcher.new(tree);

name_search = searcher.search_by(:name, "div");
class_search = searcher.search_by(:classes, "bold");
id_search = searcher.search_by(:id, "main-area");

temp = searcher.search_by(:name, "em");
ancestor_search = searcher.search_ancestors(temp[0], :classes, "silly")

temp = searcher.search_by(:name, "main");
descendents_search = searcher.search_descendents(temp[0], :classes, "silly")

temp = searcher.search_by(:name, "main");
regex_search = searcher.search_descendents(temp[0], :classes, /fun/)

renderer = NodeRenderer.new(tree);

#render base tree
renderer.render

#render test searches from above
renderer.render(name_search[0])
renderer.render(name_search[1])
renderer.render(class_search[0])
renderer.render(id_search[0])
renderer.render(ancestor_search[0])
renderer.render(descendents_search[0])
renderer.render(regex_search[0])