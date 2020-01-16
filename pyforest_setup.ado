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
	* Check to see if Stata recognizes Python
	*----------------------------------------------
	
	di in gr "Checking for Stata-compatible Python installation..."
	qui python query
	local python_path = r(execpath)
	local python_vers = r(version)
	local python_path = subinstr("`python_path'","\","/",.)
	if "`python_path'"!="" {
		di in gr "  Compatible Python installation found!"
		di in gr "  Location of Python executable: `python_path'"
		di in gr "  Python version: `python_vers'"
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
	di in gr " "
	di in gr "Looking for Python module pandas..."
	local installed 0
	cap python which pandas
	if _rc==0 {
		di in gr "  The module was found."
		local installed 1
	}
	if _rc!=0 {
		di in gr "  Warning: Could not find the module. "
	}
	
	* Auto install method 1: Python subprocess call
	cap python which pandas
	if _rc!=0 {
		di in gr "    Trying to install automatically with pip..."
		sleep 300
		python: install("`python_path'","pandas")
	}
	
	* Auto install method 2: Python subprocess call (user directory)
	cap python which pandas
	if _rc!=0 {
		di in gr "    Trying to install automatically with pip (user directory)..."
		sleep 300
		python: install_user("`python_path'","pandas")
	}
	
	* If we still do not have pandas installed, display error.
	cap python which pandas
	if _rc!=0 {
		di as error "  Error: Could not install pandas automatically. You may need to install it manually."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		exit 1
	}
	if _rc==0 & `installed'==0 {
		di in gr "  Installed pandas successfully! You may need to restart Stata for this change to take effect."
	}
	
	*----------------------------------------------
	* Check to see if we have numpy
	*----------------------------------------------
	
	* Check whether or nnot we have numpy.
	di in gr " "
	di in gr "Looking for Python module numpy..."
	local installed 0
	cap python which numpy
	if _rc==0 {
		di in gr "  The module was found."
		local installed 1
	}
	if _rc!=0 {
		di in gr "  Warning: Could not find the module. "
	}
	
	* Auto install method 1: Python subprocess call
	cap python which numpy
	if _rc!=0 {
		di in gr "    Trying to install automatically with pip..."
		sleep 300
		python: install("`python_path'","numpy")
	}
	
	* Auto install method 2: Python subprocess call (user directory)
	cap python which numpy
	if _rc!=0 {
		di in gr "    Trying to install automatically with pip (user directory)..."
		sleep 300
		python: install_user("`python_path'","numpy")
	}
	
	cap python which numpy
	if _rc!=0 {
		di as error "  Error: Could not install numpy automatically. You may need to install it manually."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		exit 1
	}
	if _rc==0 & `installed'==0 {
		di in gr "  Installed numpy successfully!"
	}
	
	*----------------------------------------------
	* Check to see if we have Scikit-learn
	*----------------------------------------------
	
	* Check whether or nnot we have sklearn.
	di in gr " "
	di in gr "Looking for Python module sklearn..."
	local installed 0
	cap python which sklearn
	if _rc==0 {
		di in gr "  The module was found."
		local installed 1
	}
	if _rc!=0 {
		di in gr "  Warning: Could not find the module. "
	}
	
	* Auto install method 1: Python subprocess call
	cap python which sklearn
	if _rc!=0 {
		di in gr "    Trying to install automatically with pip..."
		sleep 300
		python: install("`python_path'","sklearn")
	}
	
	* Auto install method 2: Python subprocess call (user directory)
	cap python which pandas
	if _rc!=0 {
		di in gr "    Trying to install automatically (user directory)..."
		sleep 300
		python: install_user("`python_path'","sklearn")
	}
	
	cap python which sklearn
	if _rc!=0 {
		di as error "  Error: Could not install scikit-learn automatically. You may need to install it manually."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		exit 1
	}
	if _rc==0 & `installed'==0 {
		di in gr "  Installed sklearn successfully!"
	}

	*----------------------------------------------
	* Check to see if we have SFI (definitely should have this, comes w/ Stata 16)
	*----------------------------------------------
	
	di in gr " "
	di in gr "Looking for Python module sfi..."
	cap python which sfi
	if _rc!=0 {
		di as error "  Error: Could not find module sfi. This should come automatically with Stata 16. Weird."
		exit 1
	}
	else {
		di in gr "  sfi was found!"
	}
	
	*----------------------------------------------
	* Wrap up
	*----------------------------------------------
	
	di in gr " "
	di in gr "Done! All prerequisites for pyforest are installed."
	di in gr "You may need to restart Stata for any installed Python modules to become available."
	di in gr " "
	
end

*-------------------------------------------------------------------------------
* Helper function for python subprocess check call
*-------------------------------------------------------------------------------

python:

def install(python_path, package):
	import subprocess
	failed = 0
	try:
		subprocess.check_call([python_path, "-m", "pip", "install", package])
	except subprocess.CalledProcessError:
		failed = 1

def install_user(python_path, package):
	import subprocess
	failed = 0
	try:
		subprocess.check_call([python_path, "-m", "pip", "install", "--user", package])
	except subprocess.CalledProcessError:
		failed = 1
	
end