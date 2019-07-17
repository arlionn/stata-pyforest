*===============================================================================
* Program: pyforest.ado
* Purpose: Stata wrapper for random forest classification and regression
*          with scikit-learn in Python, using Stata 16's new built-in Python
*          integration functions.
* More info: www.github.com/mdroste/stata-pyforests
* Version: 0.11
* Date: July 16, 2019
* Author: Michael Droste
*===============================================================================

program define pyforest, eclass
version 16.0
syntax varlist(min=2) [if] [in] [aweight fweight], ///
[ ///
	type(string asis)            	 /// random forest type: classifier or regressor
	n_estimators(integer 100) 	 	 /// number of trees
	criterion(string asis) 	 	 	 /// split criterion (gini, entropy)
	max_depth(integer -1)	 	 	 /// max tree depth
	min_samples_split(real 2) 	 	 /// min obs before splitting internal node
	min_samples_leaf(real 1) 	 	 /// min obs required at a leaf node
	min_weight_fraction_leaf(real 0) /// min weighted frac of sum of total weights
	max_features(string asis)	 	 /// number of features to consider for best split
	max_leaf_nodes(real -1)	 	 	 /// max leaf nodes
	min_impurity_decrease(real 0)	 /// split if it induces this amt decrease in impurity
	nobootstrap 		 		 	 /// use bootstrap or not
	oob_score 		 		 	 	 /// whether to use out-of-bag obs to estimate generalization accuracy
	n_jobs(integer -1)		 	 	 /// number of processors to use when computing stuff - default is all
	random_state(integer -1) 	 	 /// seed used by random number generator
	verbose		 			 	 	 /// controls verbosity
	warm_start(string asis)	 	 	 /// when set to true, reuse solution of previous call to fit
	class_weight 			 	 	 /// XX NOT YET IMPLEMENTED
    frac_training(real 0.5)	 	 	 /// randomly assign fraction X to training
    training_stratify 		 	 	 /// if nonmissing, randomize at this level
    training_identifier(varname) 	 /// training dataset identifier
	save_prediction(string asis) 	 /// variable name to save predictions
	save_training(string asis) 	 	 /// variable name to save training flag
	standardize                  	 /// standardize features XX NOT YET IMPLEMENTED
]


*-------------------------------------------------------------------------------
* Handle arguments
*-------------------------------------------------------------------------------

* Pass varlist into varlists called yvar and xvars
*--------------
gettoken yvar xvars : varlist

*--------------
* n_estimators: positive integer (default: 10)
if `n_estimators'<1 {
	di as error "Syntax error: Number of trees must be a positive integer (was `n_estimators')"
	exit 1
}

*--------------
* type: string asis, either classify or regress
if "`type'"=="" {
	di as error "ERROR: type() option needs to be specified. Valid options: type(classify) or type(regress)"
	exit 1
}
if ~inlist("`type'","classify","regress") {
	di as error "Syntax error: invalid choice for type (chosen: `type'). Valid options are classify or regress"
	exit 1
}

*--------------
* criterion option: different for classifier or regressor
if "`type'"=="classify" & "`criterion'"=="" local criterion "gini"
if "`type'"=="regress"  & "`criterion'"=="" local criterion "mse"
if "`type'"=="classify" {
	if ~inlist("`criterion'","gini","entropy") {
		di as error "Syntax error: with type(`type'), criterion() must be 'gini' or 'entropy' (was `criterion')"
		exit 1
	}
}
if "`type"=="regress" {
	if ~inlist("`criterion'","mse","mae") {
		di as error "Syntax error: with type(`type'), criterion() must be 'mse' or 'mae' (was `criterion')"
		exit 1
	}
}

*--------------
* max_depth: positive integer (default: None)
if "`max_depth'"=="-1" local max_depth None
if "`max_depth'"!="None" {
	if `max_depth'<1 {
		di as error "Syntax error: max_depth() must be positive integer (was `max_depth')"
		exit 1
	}
}

*--------------
* min_samples_split: int, float, optional  (default: 2)
if "`min_samples_split'"=="" local min_samples_split 2

*--------------
* min_samples_leaf: int, float, optional (default: 1) 
if "`min_samples_leaf'"=="" local min_samples_leaf 1

*--------------
* min_weight_fraction_leaf: float, optional (default: 0)
if "`min_weight_fraction_leaf'"=="" local min_weight_fraction_leaf 0

*--------------
* max_features 
* int, float, string, or None, optional (default: "auto")
if "`max_features'"=="" local max_features "auto"
* if not sqrt or log2, then should be float
if ~inlist("`max_features'","auto","sqrt","log2") {
	* check to make sure float
	cap confirm number `max_features'
	if _rc>0 {
		di as error "Syntax error: max_features() should be either 'auto', 'sqrt', 'log2', or an integer/float (was `max_features')"
		exit 1
	}
	if _rc==0 {
		* xx need to apply ceil thing here
	}
}
else {
	local max_features `""`max_features'""'
}

*--------------
* max_leaf_nodes: xx test me
if "`max_leaf_nodes'"=="-1" local max_leaf_nodes None
if "`max_leaf_nodes'"!="None" {
	if `max_leaf_nodes'<1 {
		di as error "Syntax error: if you specify max_leaf_nodes(), make it a positive integer (was `max_leaf_nodes')"
		exit 1
	}
}

*--------------
* min_impurity_decrease: xx test me
if "`min_impurity_decrease'"=="" local min_impurity_decrease 0

*--------------
* nobootstrap: whether or not to bootstrap samples in each tree
if "`nobootstrap'"=="" local bootstrap True
if "`nobootstrap'"!="" local bootstrap False

*--------------
* oob_score: xx not yet implemented
if "`oob_score'"=="" local oob_score False

*--------------
* n_jobs: number of processors to use in computing random forests
if "`n_jobs'"=="" local n_jobs -1
if `n_jobs'<1 & `n_jobs'!=-1 {
	di as error "Syntax error: num_jobs() must be positive integer or -1."
	di as error " num_jobs() specifies number of processors to use; the default -1 means all."
	di as error " If not -1, this has to be a positive integer. But you should probably not mess around with this."
	exit 1
}

*--------------
* random_state: initialize random number generator
if "`random_state'"=="-1" local random_state None
if "`random_state'"!="" & "`random_state'"!="None" {
	if `random_state'<1 {
		di as error "Syntax error: random_state should be a positive integer."
		exit 1
	}
	set seed `random_state'
}

*--------------
* verbose: control verbosity of python output
if "`verbose'"=="" local verbose 0

*--------------
* warm_start: Unsupported scikit-learn option used to use pre-existing rf object 
if "`warm_start'"=="" local warm_start False

*--------------
* class_weight: xx not yet implemented
if "`class_weight'"=="" local class_weight None

*--------------
* frac_training: fraction of dataset to sample randomly from
if `frac_training'<=0 | `frac_training'>1 {
	di as error "Syntax error: frac_training() should take value in range (0,1]."
	exit 1
}

*--------------
* prediction cant already be a variable name
if "`save_prediction'"=="" local save_prediction _rf_prediction
capture confirm new variable `save_prediction'
if _rc>7 {
	di as error "Error: save_prediction() cannot specify an existing variable (`save_prediction' already exists)"
	exit 1
}

*--------------
* training dataset indicator cant already be a variable name
if "`save_training'"=="" {
	local save_training _rf_training
}
capture confirm new variable `save_training'
if _rc>7 {
	di as error "Error: save_training() cannot specify an existing variable (`save_training' already exists)"
	exit 1
}

*--------------
* feature importance
local importance 0
if "`feature_importance'"!="" local importance 1

*-------------------------------------------------------------------------------
* Manipulate data
*-------------------------------------------------------------------------------

* generate an index of original data so we can easily merge back on the results
*  xx there is probably a better way to do this... feels inefficient
tempvar index
gen `index' = _n

* preserve original data
preserve

* restrict sample with if and in
marksample touse, strok novarlist
qui drop if `touse'==0

* if classification: check to see if y needs encoding to numeric
local yvar2 `yvar'
if "`type'"=="classify" {
	capture confirm numeric var `yvar'
	if _rc>0 {
		local needs_encoding "yes"
		encode `yvar', gen(`yvar'_encoded)
		noi di "Encoded `yvar' as `yvar'_encoded"
		local yvar2 `yvar'_encoded
	}
}

* restrict sample to jointly nonmissing observations
foreach v of varlist `varlist' {
	qui drop if mi(`v')
}

* Define a training subsample called `save_training'
if "`training_identifier'"!="" {
	rename `training_identifier' `save_training'
}
if "`training_identifier'"=="" {
	gen `save_training' = runiform()<`frac_training'
}

* Get number of obs in train and validate samples
qui count if `save_training'==1
local num_obs_train = `r(N)'
qui count
local num_obs_val = `r(N)' - `num_obs_train'

*-------------------------------------------------------------------------------
* Format strings and display text box
*-------------------------------------------------------------------------------

* Store a macro to slightly change results table
if "`type'"=="regress" local type_str "regression"
if "`type'"=="classify" local type_str "classification"

* Display some info about options
di "{hline 80}"
di in ye "Random forest `type_str'"
di in gr "Dependent variable: `yvar'" _continue
di in gr _col(52) "Num. training obs   = " in ye `num_obs_train'
di in gr "Features: `xvars'" _continue
di in gr _col(52) "Num. validation obs = " in ye `num_obs_val'
di in gr "Number of trees: " in ye "`n_estimators'"
di in gr "Max tree depth: " in ye "`max_depth'"
di in gr "Max features: " in ye `max_features'
di in gr "Max leaf nodes: " in ye "`max_leaf_nodes'"
di in gr "Min obs at each leaf: " in ye "`min_samples_leaf'"
di in gr "Min obs at internal nodes: " in ye "`min_samples_split'"
di in gr "Min weight fraction leaf " in ye "`min_weight_fraction_leaf'"
di in gr "Splitting criterion: " in ye "`criterion'"
di in gr "Min impurity decrease: " in ye "`min_impurity_decrease'"
di in gr "Saved prediction: " in ye "`save_prediction'"
di "{hline 80}"

* Pass options to Python to import data, run random forest regression, return results
python: run_random_forest( ///
	"`type'", ///
	"`save_training' `yvar2' `xvars'", ///
	`n_estimators', ///
	"`criterion'", ///
	`max_depth', ///
	`min_samples_split', ///
	`min_samples_leaf', ///
	`min_weight_fraction_leaf', ///
	`max_features', ///
	`max_leaf_nodes', ///
	`min_impurity_decrease', ///
	`bootstrap', ///
	`oob_score', ///
	`n_jobs', ///
	`random_state', ///
	`verbose', ///
	`warm_start', ///
	`class_weight', ///
	"`save_prediction'", ///
	"`save_training'", ///
	`importance')

*-------------------------------------------------------------------------------
* Clean up before ending Stata script
*-------------------------------------------------------------------------------

* keep only index and new data
keep `index' `save_prediction' `save_training'
tempfile t1
qui save `t1'
restore
qui merge 1:1 `index' using `t1', nogen
drop `index'

* If save training was specified, delete temporary save_training var
if "`save_training'"!="" {
	*drop `save_training'
}

* If y needed encoding, decode
* XX this is inefficient
if "`needs_encoding'"=="yes" {
	tempvar encode1
	encode `yvar', gen(`encode1')
	label values `save_prediction' `encode1'
	decode `save_prediction', gen(`save_prediction'_2)
	drop `save_prediction'
	rename `save_prediction'_2 `save_prediction'
}

*-------------------------------------------------------------------------------
* Finally: send stuff out to e() class
*-------------------------------------------------------------------------------

* Return importance
ereturn matrix importance = temp1

end

*-------------------------------------------------------------------------------
* Python code
*-------------------------------------------------------------------------------

version 16.0
python:

# Import pandas, numpy, and Data module of stata function interface
import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier
from sklearn.ensemble import RandomForestRegressor
from sfi import Data
from sfi import Matrix

#------------------------------------------------------
# Define function: run_random_forests_regressor
#------------------------------------------------------

def run_random_forest(type,vars,n_estimators,criterion,max_depth,min_samples_split,min_samples_leaf,min_weight_fraction_leaf,max_features,max_leaf_nodes,min_impurity_decrease,bootstrap,oob_score,n_jobs,random_state,verbose,warm_start,class_weight,prediction,training,importance):

	# Load data into data frame
	df = pd.DataFrame(Data.get(vars))
	colnames = []
	for var in vars.split():
		 colnames.append(var)
	df.columns = colnames

	# Split training data and test data into separate data frames
	df_train, df_test = df[df[training]==1], df[df[training]==0]

	# Create list of feature names
	features = df.columns[2:]
	y        = df.columns[1]

    # Initialize random forest regressor
	if type=="regress":
		rf = RandomForestRegressor(n_estimators=n_estimators, criterion=criterion, max_depth=max_depth, min_samples_split=min_samples_split, min_samples_leaf=min_samples_leaf, min_weight_fraction_leaf=min_weight_fraction_leaf, max_features=max_features, max_leaf_nodes=max_leaf_nodes, min_impurity_decrease=min_impurity_decrease, bootstrap=bootstrap, oob_score=oob_score, n_jobs=n_jobs, random_state=random_state, verbose=verbose, warm_start=warm_start)

	if type=="classify":
		rf = RandomForestClassifier(n_estimators=n_estimators, criterion=criterion, max_depth=max_depth, min_samples_split=min_samples_split, min_samples_leaf=min_samples_leaf, min_weight_fraction_leaf=min_weight_fraction_leaf, max_features=max_features, max_leaf_nodes=max_leaf_nodes, min_impurity_decrease=min_impurity_decrease, bootstrap=bootstrap, oob_score=oob_score, n_jobs=n_jobs, random_state=random_state, verbose=verbose, warm_start=warm_start)

    # Run random forest regressor on training data
	rf.fit(df_train[features], df_train[y])

	# Generate predictions (on both training and test data)
	pred    = rf.predict(df[features])

	# Export predictions to Stata
   	Data.addVarFloat(prediction)
	Data.store(prediction,None,pred)

	# If applicable, display feature importance
	feature_importances = pd.DataFrame(rf.feature_importances_,
										index = features,
										columns=['importance']).sort_values('importance', ascending=False)
	z = feature_importances.shape
	importance = list(rf.feature_importances_)
	Matrix.create("importance", z[0], z[1], -1)
	Matrix.setColNames("importance",['importance'])
	Matrix.setRowNames("importance",list(features.values))
	print(importance[0])
	for i in range(z[0]):
		print(i)
		Matrix.storeAt("importance",i,0,importance[i])

end
