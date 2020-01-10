*===============================================================================
* FILE: pyforest_p.ado
* PURPOSE: Enables post-estimation -predict- command to obtain fitted values
*   from pyforest.ado (random forest regression/classification with scikit-learn)
* SEE ALSO: pyforest.ado
*===============================================================================

program define pyforest_p, eclass
	version 16.0
	syntax anything(id="argument name" name=arg) [if] [in], [pr]
	
	* Mark sample with if/in
	marksample touse, novarlist
	
	* Count number of variables
	local numVars : word count `arg'
	if `numVars'!=1 {
		di as error "Error: More than 1 prediction variable specified"
		exit 1
	}
	
	* Define locals prediction, features
	local predict_var "`arg'"
	local features "${features}"
	
	* Generate an index variable for merging on obs number
	tempvar temp_index
	gen `temp_index' = _n
	tempfile t1
	qui save `t1'
	
	* Keep only if touse
	qui keep if `touse'==1
	
	* Also only keep joint nonmissing over features
	foreach v of varlist `features' {
		qui drop if mi(`v')
	}

	
	* Get predictions
	python: post_prediction("`features'","`predict_var'")
	
	* Keep only prediction and index
	keep `predict_var' `temp_index'
	tempfile t2
	qui save `t2'
	
	* Load original dataset, merge prediction on
	qui use `t1', clear
	qui merge 1:1 `temp_index' using `t2', nogen
	
	
	
end

python:

def post_prediction(vars, prediction):

	# Import random forest object data from main namespace
	from __main__ import rf_object as rf
	from pandas import DataFrame
	from sklearn.ensemble import RandomForestClassifier,RandomForestRegressor
	from sfi import Data,Matrix
	
	# Load data into Pandas data frame
	df = DataFrame(Data.get(vars))
	colnames = []
	for var in vars.split():
		 colnames.append(var)
	df.columns = colnames
	
	# Create list of feature names
	features = df.columns[0:]
	
	# Generate predictions (on both training and test data)
	pred    = rf.predict(df[features])
	
	# Export predictions back to Stata
   	Data.addVarFloat(prediction)
	Data.store(prediction,None,pred)
	
	
end