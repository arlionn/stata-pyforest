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
* Check to see if we have pandas
*-------------------------------------------------------------------------------

* Local to hold module name
local modname pandas

* Check whether or nnot we have Pandas.
di in gr " "
di in gr "Looking for Python module `modname'..."
local installed 0
cap python which `modname'
if _rc==0 {
	di in gr "  The module `modname' was found."
	local installed 1
}
if _rc!=0 {
	di in gr "  Warning: Could not find the module `modname'. "
}
	
* If we could not find the module...
if `installed'==0 {
    
	* Try to install automatically with pip
	di in gr "    Trying to install `modname' automatically with pip..."
	sleep 300
	python: install_mod("`python_path'","`modname'")
	
	* Parse errors
	if `pf_install'==0 {
		di as error "  Error: Could not install `modname' automatically. You may need to install it manually."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		exit 1
	}
}
	
*-------------------------------------------------------------------------------
* Check for numpy
*-------------------------------------------------------------------------------

* Local to hold module name
local modname numpy

* Check whether or nnot we have Pandas.
di in gr " "
di in gr "Looking for Python module `modname'..."
local installed 0
cap python which `modname'
if _rc==0 {
	di in gr "  The module `modname' was found."
	local installed 1
}
if _rc!=0 {
	di in gr "  Warning: Could not find the module `modname'. "
}
	
* If we could not find the module...
if `installed'==0 {
    
	* Try to install automatically with pip
	di in gr "    Trying to install `modname' automatically with pip..."
	sleep 300
	python: install_mod("`python_path'","`modname'")
	
	* Parse errors
	if `pf_install'==0 {
		di as error "  Error: Could not install `modname' automatically. You may need to install it manually."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		exit 1
	}
}

*-------------------------------------------------------------------------------
* Check for scikit-learn (sklearn)
*-------------------------------------------------------------------------------

* Local to hold module name
local modname sklearn

* Check whether or nnot we have Pandas.
di in gr " "
di in gr "Looking for Python module `modname'..."
local installed 0
cap python which `modname'
if _rc==0 {
	di in gr "  The module `modname' was found."
	local installed 1
}
if _rc!=0 {
	di in gr "  Warning: Could not find the module `modname'. "
}
	
* If we could not find the module...
if `installed'==0 {
    
	* Try to install automatically with pip
	di in gr "    Trying to install `modname' automatically with pip..."
	sleep 300
	python: install_mod("`python_path'","`modname'")
	
	* Parse errors
	if `pf_install'==0 {
		di as error "  Error: Could not install `modname' automatically. You may need to install it manually."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		exit 1
	}
}

*-------------------------------------------------------------------------------
* Check for sfi (stata function interface - should come with stata 16)
*-------------------------------------------------------------------------------

* Local to hold module name
local modname sfi

* Check whether or nnot we have Pandas.
di in gr " "
di in gr "Looking for Python module `modname'..."
local installed 0
cap python which `modname'
if _rc==0 {
	di in gr "  The module `modname' was found."
	local installed 1
}
if _rc!=0 {
	di in gr "  Warning: Could not find the module `modname'. "
}
	
* If we could not find the module...
if `installed'==0 {
    
	* Try to install automatically with pip
	di in gr "    Trying to install `modname' automatically with pip..."
	sleep 300
	python: install_mod("`python_path'","`modname'")
	
	* Parse errors
	if `pf_install'==0 {
		di as error "  Error: Could not install `modname' automatically. You may need to install it manually."
		di as error "  Please see the help file ({help pyforest_setup:help pyforest_setup}) for more info."
		exit 1
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