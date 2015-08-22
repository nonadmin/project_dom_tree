# DOM_reader takes the idea of the tag parser and scales it up to the entire HTML
# document.  We break down each HTML element using one regex and store that as a
# node.  We then search through the "data" of that element to determine if it has
# any children, and so on until the entire document has been parsed into a tree.

