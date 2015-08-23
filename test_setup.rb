require_relative 'node_renderer'

# sample code
d = DOMReader.new
tree = d.build_tree('test.html');
searcher = TreeSearcher.new(tree);
search_one = searcher.search_by(:name, "div");
search_two = searcher.search_by(:classes, "bold");
search_three = searcher.search_by(:id, "main-area");

search_four = searcher.search_by(:name, "em");
search_five = searcher.search_ancestors(search_four[0], :classes, "silly")

search_six = searcher.search_by(:name, "main");
search_seven = searcher.search_descendents(search_six[0], :classes, "silly")

search_eight = searcher.search_by(:name, "main");
search_nine = searcher.search_descendents(search_eight[0], :classes, /fun/)

renderer = NodeRenderer.new(tree);
renderer.render
renderer.render(search_one[0])
renderer.render(search_one[1])
renderer.render(search_two[0])
renderer.render(search_three[0])
renderer.render(search_five[0])
renderer.render(search_seven[0])
renderer.render(search_nine[0])