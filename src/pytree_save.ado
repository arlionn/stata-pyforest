*===============================================================================
* FILE: pytree_save.ado
* PURPOSE: Enables post-estimation save of decision tree node chart
* SEE ALSO: pyforest.ado
* AUTHOR: Michael Droste
*===============================================================================

program define pytree_save
	version 16.0
	
	* parse arguments
	syntax anything(id="argument name" name=arg), [replace]
	
	* Count number of variables
	local numVars : word count `arg'
	if `numVars'!=1 {
		di as error "Please use one word as filename"
		exit 1
	}
	
	*---------------------------------------------------
	* Clean up argument (filename)
	*---------------------------------------------------
	
	* If filename ends in .png, we are good to good
	if strpos("`arg'",".png")>0 {
		local filename = "`arg'"
	}
	
	* Otherwise...
	if strpos("`arg'",".png")==0 {
		
		* If . exists, throw error
		if strpos("`arg'",".")>0 {
			di as error "Error: filename `arg' can only end in .png."
			exit 1
		}
		
		* If . does not exist, append with .png
		if strpos("`arg'",".")>0 {
			local filename = "`arg'" + ".png"
		}
		
	*---------------------------------------------------
	* Check to see if filename exists, throw error if replace not specified
	*---------------------------------------------------
	
	* Run Python code
	python: save_tree("`filename'")
	
	
end

python:

def save_tree(filename):

	# Try to import tree and feature names from main namespace
	try:
		from __main__ import tree as tree
		from __main__ import features as features
	except ImportError:
		print("Could not find decision tree in memory. Run pytree before using this command.")
	
	# Import matplotlib
	from matplotlib import pyplot as plt
	from sklearn import tree
	
	# Hot fix for Anaconda 3
	import os 
	os.environ['QT_QPA_PLATFORM_PLUGIN_PATH'] = "C:/Users/Mike/Anaconda3/Library/plugins"
	
	# Plot tree
	tree.plot_tree(tree)
	
	# Save out
	plt.savefig(filename, dpi=72, facecolor='w', edgecolor='w',
        orientation='portrait', papertype=None, format=None,
        transparent=False, bbox_inches=None, pad_inches=0.1,
        frameon=None, metadata=None)
	
end