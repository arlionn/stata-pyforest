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
	
	* First: Check to see if we have Python, and it is version 3 or above
	di "Looking for a Python 3.0+ installation..."
	qui python query
	local python_path = r(execpath)
	local python_vers = r(version)
	local python_path = subinstr("`python_path'","\","/",.)
	if "`python_path'"!="" & substr("`python_vers'",1,1)=="3" {
		di "  Compatible Python installation found!"
		di "  Path to installation: `python_path'"
		di "  Python version: `python_vers'"
	}
	if "`python_path'"=="" {
		di as error "  Error: No python path found! Do you have Python 3.0+ installed?"
		di as error "  If you do, use the Stata command -set pythonpath (path to python executable), permanently-"
		di as error "  If you're not sure, use the Stata command -python search- to look for Python installations."
		exit 1
	}
	if substr("`python_vers'",1,1)!="3" {
		di as error "  Error: pyforest requires Python 3.0+. The Python executable that was detected is version `python_vers'"
		di as error "  Stata thinks your Python executable is located at: `python_path'"
		di as error "  Use the Stata command {python search:python search} to look for other installations, or use -set pythonpath (Python executable path)- to point to a Python 3.0+ installation."
		exit 1
	}

	* Check to see if we have pandas
	di " "
	di "Looking for Python module pandas..."
	sleep 500
	cap python which pandas
	if _rc!=0 {
		di "  Warning: Could not find module pandas. Trying to install automatically with pip...."
		sleep 500
		*cap python: install("`python_path'","pandas")
		cap python which pandas
		if _rc!=0 shell pip3 install pandas
		cap python which pandas
		if _rc!=0 {
			di as error "  Error: Could not install pandas automatically with pip."
			di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
			di as error "  Note that automatic installation requires internet access (can you ssc install stuff?)"
			exit 1
		}
		if _rc==0 {
			di "  Installed pandas successfully!"
		}
	}
	else {
		di " pandas was found!"
	}

	* Check to see if we have numpy
	di " "
	di "Looking for Python module NumPy..."
	sleep 500
	cap python which numpy
	if _rc!=0 {
		di "  Warning: Could not find module numpy. Trying to install automatically with pip...."
		sleep 500
		*cap python: install("`python_path'","numpy")
		cap python which numpy
		if _rc!=0 shell pip3 install numpy
		cap python which numpy
		if _rc!=0 {
			di as error "  Error: Could not install numpy automatically with pip."
			di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
			di as error "  Note that automatic installation requires internet access (can you ssc install stuff?)"
			exit 1
		}
		if _rc==0 {
			di "  Installed numpy successfully!"
		}
	}
	else {
		di " numpy was found!"
	}
	
	* Check to see if we have Scikit-learn
	di " "
	di "Looking for Python module scikit-learn (sklearn)..."
	sleep 500
	cap python which sklearn
	if _rc!=0 {
		di "  Warning: Could not find module sklearn. Trying to install automatically with pip...."
		sleep 500
		*cap python: install("`python_path'","sklearn")
		cap python which numpy
		if _rc!=0 shell pip3 install sklearn
		cap python which sklearn
		if _rc!=0 {
			di as error "  Error: Could not install sklearn automatically with pip."
			di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
			di as error "  Note that automatic installation requires internet access (can you ssc install stuff?)"
			exit 1
		}
		if _rc==0 {
			di "  Installed scikit-learn (sklearn) successfully!"
		}
	}
	else {
		di " sklearn was found!"
	}

	* Check to see if we have SFI (definitely should have this, comes w/ Stata 16)
	di " "
	di "Looking for sfi module..."
	cap python which sfi
	if _rc!=0 {
		di as error "  Error: Could not find module sfi. This should come automatically with Stata 16. Weird."
		exit 1
	}
	else {
		di " sfi was found!"
	}
	
	di " "
	di "Awesome! All prerequisite packages are installed. Pyforest should now work."
	
end

*-------------------------------------------------------------------------------
* Helper function for python
*-------------------------------------------------------------------------------

python:

def install(python_path, package):
	import subprocess, sys
	subprocess.check_call([python_path, "-m", "pip", "install", package])
	
end