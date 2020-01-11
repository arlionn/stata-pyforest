*===============================================================================
* FILE: pyforest_setup.ado
* PURPOSE: Checks for pyforest Python prereqs and tries to install w/ pip
* SEE ALSO: pyforest.ado
* AUTHOR: Michael Droste
*===============================================================================


*-------------------------------------------------------------------------------
* Stata component
*-------------------------------------------------------------------------------

program define pyforest_setup
	version 16.0
	
	* Display some startup...
	di "This program checks to make sure that you have the necessary Python prequisites to run the Stata module pyforest."
	di " "
	
	*----------------------------------------------
	* Check to see if we have Python 3.0+
	*----------------------------------------------
	
	di "Looking for a Python 3.0+ installation..."
	qui python query
	local python_path = r(execpath)
	local python_vers = r(version)
	local python_path = subinstr("`python_path'","\","/",.)
	if "`python_path'"!="" {
		di "  Compatible Python installation found!"
		di "  Path to installation: `python_path'"
		di "  Python version: `python_vers'"
	}
	if "`python_path'"=="" {
		di as error "  Error: No python path found! Do you have Python 2.7+ installed?"
		di as error "  If you do have Python installed, use the Stata command -{set python_path:set python_path}, permanently- to tell Stata where to look."
		di as error "  If you do not have Python installed (or are not sure if you do), I recommend downloading Anaconda, which includes everything you need out of the box and will be detected automatically by Stata."
		di as error "  Anaconda: https://www.anaconda.com/distribution/#download-section"
		exit 1
	}

	*----------------------------------------------
	* Check to see if we have pandas
	*----------------------------------------------
	
	* Check whether or nnot we have Pandas.
	di " "
	di "Looking for Python module pandas..."
	local installed 0
	cap python which pandas
	if _rc==0 {
		di "  The module was found."
		local installed 1
	}
	if _rc!=0 {
		di "  Warning: Could not find the module. "
	}
	
	* First try to install: Python subprocess call
	cap python which pandas
	if _rc!=0 {
		di "    Trying to install automatically with Python subprocess call to pip..."
		sleep 300
		cap python: install("`python_path'","pandas")
	}

	* Second try: Shell call with python -m to identify pip version
	cap python which pandas
	if _rc!=0 {
		di "    Trying to install automatically with Stata shell call to pip..."
		sleep 300
		shell `python_path' -m pip install pandas
	} 
	
	* Last try: Shell call with python -m to identify pip version, user dir
	cap python which pandas
	if _rc!=0 {
		di "    Trying to install automatically with Stata shell call to pip (user directory installation)..."
		sleep 300
		shell `python_path' -m pip install --user pandas
	} 
	
	cap python which pandas
	if _rc!=0 {
		di as error "  Error: Could not install pandas automatically with pip."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		di as error "  Note that automatic installation requires internet access (can you ssc install stuff?)"
		exit 1
	}
	if _rc==0 & `installed'==0 {
		di "  Installed pandas successfully! You may need to restart Stata for this change to take effect."
	}
	
	*----------------------------------------------
	* Check to see if we have numpy
	*----------------------------------------------
	
	* Check whether or nnot we have numpy.
	di " "
	di "Looking for Python module numpy..."
	local installed 0
	cap python which numpy
	if _rc==0 {
		di "  The module was found."
		local installed 1
	}
	if _rc!=0 {
		di "  Warning: Could not find the module. "
	}
	
	* First try to install: Python subprocess call
	cap python which numpy
	if _rc!=0 {
		di "    Trying to install automatically with Python subprocess call to pip..."
		sleep 300
		cap python: install("`python_path'","numpy")
	}

	* Second try: Shell call with python -m to identify pip version
	cap python which numpy
	if _rc!=0 {
		di "    OK, that didn't work!"
		di "    Trying to install automatically with Stata shell call to pip..."
		sleep 300
		shell `python_path' -m pip install numpy
	} 
	
	* Last try: Shell call with python -m to identify pip version, user dir
	cap python which numpy
	if _rc!=0 {
		di "    Trying to install automatically with Stata shell call to pip (user directory installation)..."
		sleep 300
		shell `python_path' -m pip install --user numpy
	} 
	
	cap python which numpy
	if _rc!=0 {
		di as error "  Error: Could not install numpy automatically with pip."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		di as error "  Note that automatic installation requires internet access (can you ssc install stuff?)"
		exit 1
	}
	if _rc==0 & `installed'==0 {
		di "  Installed numpy successfully!"
	}
	
	*----------------------------------------------
	* Check to see if we have Scikit-learn
	*----------------------------------------------
	
	* Check whether or nnot we have sklearn.
	di " "
	di "Looking for Python module sklearn..."
	local installed 0
	cap python which sklearn
	if _rc==0 {
		di "  The module was found."
		local installed 1
	}
	if _rc!=0 {
		di "  Warning: Could not find the module. "
	}
	
	* First try to install: Python subprocess call
	cap python which sklearn
	if _rc!=0 {
		di "    Trying to install automatically with Python subprocess call to pip..."
		sleep 300
		*cap python: install("`python_path'","sklearn")
	}

	* Second try: Shell call with python -m to identify pip version
	cap python which sklearn
	if _rc!=0 {
		di "    OK, that didn't work!"
		di "    Trying to install with Stata shell call to pip..."
		sleep 300
		shell `python_path' -m pip install sklearn
	} 
	
	* Last try: Shell call with python -m to identify pip version, user dir
	cap python which sklearn
	if _rc!=0 {
		di "    Trying to install automatically with Stata shell call to pip (user directory installation)..."
		sleep 300
		shell `python_path' -m pip install --user sklearn
	} 
	
	cap python which sklearn
	if _rc!=0 {
		di as error "  Error: Could not install sklearn automatically with pip."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		di as error "  Note that automatic installation requires internet access (can you ssc install stuff?)"
		exit 1
	}
	if _rc==0 & `installed'==0 {
		di "  Installed sklearn successfully!"
	}

	*----------------------------------------------
	* Check to see if we have SFI (definitely should have this, comes w/ Stata 16)
	*----------------------------------------------
	
	di " "
	di "Looking for Python module sfi..."
	cap python which sfi
	if _rc!=0 {
		di as error "  Error: Could not find module sfi. This should come automatically with Stata 16. Weird."
		exit 1
	}
	else {
		di "  sfi was found!"
	}
	
	*----------------------------------------------
	* Wrap up
	*----------------------------------------------
	
	di " "
	di "Done! All prerequisites for pyforest are installed."
	di "You may need to restart Stata for any installed Python modules to become available."
	di " "
	
end

*-------------------------------------------------------------------------------
* Helper function for python subprocess check call
*-------------------------------------------------------------------------------

python:

def install(python_path, package):
	import subprocess, sys
	subprocess.check_call([python_path, "-m", "pip", "install", package])
	
end