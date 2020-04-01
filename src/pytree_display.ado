*===============================================================================
* FILE: pytree_display.ado
* PURPOSE: Enables post-estimation display of decision tree
* SEE ALSO: pyforest.ado
* AUTHOR: Michael Droste
*===============================================================================

program define pytree_display, eclass
	version 16.0
	
	python: display_tree()
	
	
end

python:

def display_tree():

	# Try to import tree and feature names from main namespace
	try:
		from __main__ import tree as tree
		from __main__ import features as features
	except ImportError:
		print("Could not find decision tree in memory. Run pytree before using this command.")
	
	# Import export_text from sklearn library
	from sklearn.tree import export_text
	
	
	# Grab text representation of tree
	r = export_text(tree, feature_names=(list(features)))
	
	# Display text representation of tree
	print(r)
	
end