from nltk.tree import *

# assign your output (generalied list of the syntax tree) to varaible text
f = open('syntaxtree.txt', 'r')
output = open('syntaxtree_output.txt', 'w')

text = f.readlines()[0]
f.close()

text = text.replace("(", "ob")    #in the syntax tree, 'ob' will display in place of '('
text = text.replace(")", "cb")    #in the syntax tree, 'cb' will display in place of ')'
text = text.replace("[", "(")
text = text.replace("]", ")")

tree = Tree.fromstring(text)
# print the tree to the output file
tree.pretty_print(nodedist=2, stream=output)   

