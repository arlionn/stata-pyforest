*===============================================================================
* FILE: pyforest_setup.ado
* PURPOSE: Checks for pyforest Python prereqs and tries to install w/ pip
* SEE ALSO: pyforest.ado
* AUTHOR: Michael Droste
*===============================================================================

*===============================================================================
* Stata component
*===============================================================================

program define pyforest_setup

version 16.0
	
* Display some startup...
di in gr "This program checks to make sure that you have the necessary Python prequisites to run the Stata module pyforest."
di " "
	
*-------------------------------------------------------------------------------
* Check to see if Stata recognizes Python
*-------------------------------------------------------------------------------
	
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

*-------------------------------------------------------------------------------
* Check for modules
*-------------------------------------------------------------------------------

* Start by assuming we have them all
local has_pandas = 1
local has_sklearn = 1
local has_numpy = 1
local has_sfi = 1

* Check for pandas
local modname pandas
di in gr " "
di in gr "Looking for Python module `modname'..."
local installed 0
cap python which `modname'
if _rc==0 {
	di in gr "  The module `modname' was found."
}
if _rc!=0 {
	di in gr "  Warning: Could not find the module `modname'. "
	local has_pandas = 0
}

* Check for numpy
local modname numpy
di in gr " "
di in gr "Looking for Python module `modname'..."
local installed 0
cap python which `modname'
if _rc==0 {
	di in gr "  The module `modname' was found."
}
if _rc!=0 {
	di in gr "  Warning: Could not find the module `modname'. "
	local has_numpy = 0
}

* Check for sklearn
local modname sklearn
di in gr " "
di in gr "Looking for Python module scikit-learn..."
local installed 0
cap python which sklearn
if _rc==0 {
	di in gr "  The module scikit-learn was found."
}
if _rc!=0 {
	di in gr "  Warning: Could not find the module scikit-learn. "
	local has_sklearn = 0
}

*-------------------------------------------------------------------------------
* If we need to install anything...
*-------------------------------------------------------------------------------

* If pandas, numpy, or sklearn not found
if `has_pandas'==0 | `has_numpy'==0 | `has_sklearn'==0 {
	
	* Look for pip, install if not found
	di in gr "We will try to install the modules we couldn't find using pip."
	di in gr " "
	di in gr "Looking for pip..."
	cap python which `pip'
	if _rc == 0 {
		di in gr "  Pip was found."
		local has_pip=1
	}
	if _rc != 0 {
		di in gr "  Warning: Could not find the module pip."
		di in gr "  Trying to install now."
		cd "`c(sysdir_plus)'"
		copy "https://bootstrap.pypa.io/get-pip.py" get-pip.py, replace
		shell `python_path' get-pip.py
		di in gr "  Installed pip. 
	}

	* Try to install pandas if necessary
	if `has_pandas'==0 {
		local modname pandas
		di in gr "    Trying to install `modname' automatically with pip..."
		sleep 300
		python: install_mod("`python_path'","`modname'")
		if `pf_install'==0 {
			di as error "  Error: Could not install `modname' automatically. You may need to install it manually."
			di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
			exit 1
		}
	}

	* Try to install numpy if necessary
	if `has_numpy'==0 {
		local modname numpy
		di in gr "    Trying to install `modname' automatically with pip..."
		sleep 300
		python: install_mod("`python_path'","`modname'")
		if `pf_install'==0 {
			di as error "  Error: Could not install `modname' automatically. You may need to install it manually."
			di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
			exit 1
		}
	}

	* Try to install sklearn if necessary
	if `has_sklearn'==0 {
		local modname scikit-learn
		di in gr "    Trying to install `modname' automatically with pip..."
		sleep 300
		python: install_mod("`python_path'","`modname'")
		if `pf_install'==0 {
			di as error "  Error: Could not install `modname' automatically. You may need to install it manually."
			di as error "  Please see  for more info."
			exit 1
		}
	}

}

*-------------------------------------------------------------------------------
* Wrap up
*-------------------------------------------------------------------------------
	
di in gr " "
di in gr "Done! All prerequisites for pyforest are installed."
di in gr "You may need to restart Stata for any installed Python modules to become available."
di in gr " "

end

*===============================================================================
* Helper function for python subprocess check call
*===============================================================================

python:

import subprocess
from sfi import Macro

def install_mod(python_path, package):
	try:
		subprocess.check_call([python_path, "-m", "pip", "install", "--user", package])
		Macro.setLocal('pf_install', '1')
	except subprocess.CalledProcessError:
		Macro.setLocal('pf_install', '0')
	
end