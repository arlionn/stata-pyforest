*===============================================================================
* Program:   pytree.ado
* Purpose:   Stata wrapper for decision tree classification and regression
*            with scikit-learn in Python, using Stata 16's new built-in Python
*            integration functions.
* More info: www.github.com/mdroste/stata-pyforest
* Version:   0.15
* Date:      January 9, 2020
* Author:    Michael Droste
*===============================================================================

program define pytree, eclass
version 16.0
syntax varlist(min=2) [if] [in] [aweight fweight], ///
[ ///
	type(string asis)            	 /// random forest type: classifier or regressor
	criterion(string asis) 	 	 	 /// split criterion (gini, entropy)
	max_depth(integer -1)	 	 	 /// max tree depth
	min_samples_split(real 2) 	 	 /// min obs before splitting internal node
	min_samples_leaf(real 1) 	 	 /// min obs required at a leaf node
	min_weight_fraction_leaf(real 0) /// min weighted frac of sum of total weights
	max_features(string asis)	 	 /// number of features to consider for best split
	max_leaf_nodes(real -1)	 	 	 /// max leaf nodes
	min_impurity_decrease(real 0)	 /// split if it induces this amt decrease in impurity
	n_jobs(integer -1)		 	 	 /// number of processors to use when computing stuff - default is all
	random_state(integer -1) 	 	 /// seed used by random number generator
	class_weight 			 	 	 /// XX NOT YET IMPLEMENTED
    training(varname) 	             /// training dataset identifier
	prediction(string asis) 	     /// variable name to save predictions
	standardize                  	 /// standardize feature variance XX NOT YET IMPLEMENTED
]

*-------------------------------------------------------------------------------
* Before doing anything: make sure we have Python 3.0+ and good modules
*-------------------------------------------------------------------------------

* First: Check to see if we have Python, and it is version 3 or above
qui python query
local python_path = r(execpath)
local python_vers = r(version)
if "`python_path'"=="" {
	di as error "Error: No python path found! Do you have Python 2.7+ installed?"
	di as error "If you do, use the Stata command -set pythonpath (path to python executable), permanently-"
	di as error "If you're not sure, use the Stata command -python search- to look for Python installations."
	exit 1
}

* Check to see if we have NumPy
cap python which numpy
if _rc!=0 {
	di as error "Error: Could not import the Python module numpy. "
	di as error: "Run the command {pyforest_setup:pyforest_setup} to try installing this from Stata."
	exit 1
}

* Check to see if we have Pandas
cap python which pandas
if _rc!=0 {
	di as error: "Error: Could not import the Python module pandas."
	di as error: "Run the command {pyforest_setup:pyforest_setup} to try installing this from Stata."
	exit 1
}

* Check to see if we have Scikit-learn
cap python which pandas
if _rc!=0 {
	di as error: "Error: Could not import the Python module scikit-learn (sklearn)."
	di as error: "Run the command {pyforest_setup:pyforest_setup} to try installing this from Stata."
	exit 1
}

* Check to see if we have SFI (definitely should have this, comes w/ Stata 16)
cap python which sfi
if _rc!=0 {
	di as error: "Error: Could not import the Python module sfi."
	di as error: "This is weird, since it should come with Stata 16..."
	exit 1
}

*-------------------------------------------------------------------------------
* Handle arguments
*-------------------------------------------------------------------------------

*-------------------------------------------------
* type: string asis, either classify or regress
*-------------------------------------------------

if "`type'"=="" {
	di as error "ERROR: type() option needs to be specified. Valid options: type(classify) or type(regress)"
	exit 1
}
if "`type'"=="reg" local type "regress"
if "`type'"=="regression" local type "regress"
if ~inlist("`type'","classify","regress") {
	di as error "Syntax error: invalid choice for type (chosen: `type'). Valid options are classify or regress"
	exit 1
}

*-------------------------------------------------
* criterion option
*-------------------------------------------------

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

*-------------------------------------------------
* max_depth: positive integer (default: None)
*-------------------------------------------------

if "`max_depth'"=="-1" local max_depth None
if "`max_depth'"!="None" {
	if `max_depth'<1 {
		di as error "Syntax error: max_depth() must be positive integer (was `max_depth')"
		exit 1
	}
}

*-------------------------------------------------
* min_samples_split: int, float, optional  (default: 2)
*-------------------------------------------------

if "`min_samples_split'"=="" local min_samples_split 2

*-------------------------------------------------
* min_samples_leaf: int, float, optional (default: 1) 
*-------------------------------------------------

if "`min_samples_leaf'"=="" local min_samples_leaf 1

*-------------------------------------------------
* min_weight_fraction_leaf: float, optional (default: 0)
*-------------------------------------------------

if "`min_weight_fraction_leaf'"=="" local min_weight_fraction_leaf 0

*-------------------------------------------------
* max_features 
* int, float, string, or None, optional (default: "auto")
*-------------------------------------------------

local max_features_di `max_features'
if "`max_features'"=="" {
	local max_features "auto"
	local max_features_di "None"
}
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

*-------------------------------------------------
* max_leaf_nodes: xx test me
*-------------------------------------------------

if "`max_leaf_nodes'"=="-1" local max_leaf_nodes None
if "`max_leaf_nodes'"!="None" {
	if `max_leaf_nodes'<1 {
		di as error "Syntax error: if you specify max_leaf_nodes(), make it a positive integer (was `max_leaf_nodes')"
		exit 1
	}
}

*-------------------------------------------------
* min_impurity_decrease: xx test me
*-------------------------------------------------

if "`min_impurity_decrease'"=="" local min_impurity_decrease 0


*-------------------------------------------------
* random_state: initialize random number generator
*-------------------------------------------------

if "`random_state'"=="-1" local random_state None
if "`random_state'"!="" & "`random_state'"!="None" {
	if `random_state'<1 {
		di as error "Syntax error: random_state should be a positive integer."
		exit 1
	}
	set seed `random_state'
	local random_state `random_state'
}

*-------------------------------------------------
* class_weight: xx not yet implemented
*-------------------------------------------------

if "`class_weight'"=="" local class_weight None

*-------------------------------------------------
* prediction: cant already be a variable name
*-------------------------------------------------

local nopredict = 0
if "`predict'"=="" {
	local nopredict = 1
    
}
capture confirm new variable `prediction'
if _rc>7 {
	di as error "Error: prediction() cannot specify an existing variable (`prediction' already exists)"
	exit 1
}

*-------------------------------------------------
* training: xx not yet implemented
*-------------------------------------------------


*-------------------------------------------------
* feature importance
*-------------------------------------------------

local importance 0
if "`feature_importance'"!="" local importance 1

*-------------------------------------------------------------------------------
* Manipulate data in Stata first
*-------------------------------------------------------------------------------

* Pass varlist into varlists called yvar and xvars
*--------------
gettoken yvar xvars : varlist
local num_features : word count `xvars'

* generate an index of original data so we can easily merge back on the results
* xx there is probably a better way to do this... feels inefficient
* xx only needs to be done if saving predictions
tempvar index
gen `index' = _n

* preserve original data
preserve

* restrict sample with if and in conditions
marksample touse, strok novarlist
qui drop if `touse'==0

* if type(classify): check to see if y needs encoding to numeric
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

* Define a temporary variable for the training sample
*cap drop rftrain
*local training_var rftrain
local training_di `training'
tempvar training_var
if "`training'"=="" {
	gen `training_var' = 1
	local training_di "None"
}
if "`training'"!="" gen `training_var' = `training'

* Get number of obs in train and validate samples
qui count if `training_var'==1
local num_obs_train = `r(N)'
qui count
local num_obs_test = `r(N)' - `num_obs_train'
local nonempty_test = `num_obs_test'>0

*-------------------------------------------------------------------------------
* Format strings and display text box
*-------------------------------------------------------------------------------

* Store a macro to slightly change results table
if "`type'"=="regress" local type_str "regression"
if "`type'"=="classify" local type_str "classification"

* Pass options to Python to import data, run random forest regression, return results
python: run_decision_tree( ///
	"`type'", ///
	"`training_var' `yvar2' `xvars'", ///
	"`criterion'", ///
	`max_depth', ///
	`min_samples_split', ///
	`min_samples_leaf', ///
	`min_weight_fraction_leaf', ///
	`max_features', ///
	`max_leaf_nodes', ///
	`min_impurity_decrease', ///
	`random_state', ///
	`class_weight', ///
	"`prediction'", ///
	"`training_var'", ///
	`importance', `nonempty_test')
	
* xx move me
if "`prediction'"=="" local prediction_di "Not specified. Use {help predict:predict} for post-estimation predictions.""
if "`prediction'"!="" local prediction_di "`prediction'"
if "`random_state'"=="None" local seed_di "None"
if "`random_state'"!="None" local seed_di `random_state'

* xx move me 2
local is_rmse: di %10.4f `e(training_rmse)'
local is_mae: di %10.4f `e(training_mae)'
local os_rmse: di %10.4f `e(test_rmse)'
local os_mae: di %10.4f `e(test_mae)'
local train_obs_f: di %10.0fc `num_obs_train'
local test_obs_f: di %10.0fc `num_obs_test'

* xx move me 3: truncate dependent var name
local yvarlen = length("`yvar'")
local yvar_fmt = "`yvar'"
if `yvarlen'>13 {
	local yvar_fmt = substr("`yvar'",1,13) + "..."
}

* Display output
noi di "{hline 80}"
noi di in ye "Decision tree `type_str'"
noi di " "
noi di in gr "{ul:Data}"
noi di in gr "Dependent variable  = " in ye "`yvar_fmt'" _continue
noi di in gr _col(41) "Number of training obs   = " in ye `train_obs_f'
noi di in gr "Number of features  = " in ye `num_features' _continue
noi di in gr _col(41) "Number of validation obs = " in ye `test_obs_f'
noi di in gr "Training identifier = " in ye "`training_di'"
noi di " "
noi di in gr "{ul:Decision tree settings}"
noi di in gr "Max tree depth      = " in ye "`max_depth'" _continue
noi di in gr _col(41) "Min obs/leaf              = " in ye "`min_samples_leaf'"
noi di in gr "Max features/tree   = " in ye "`max_features_di'" _continue
noi di in gr _col(41) "Min obs/interior node     = " in ye "`min_samples_split'"
noi di in gr "Max leaf nodes      = " in ye "`max_leaf_nodes'" _continue
noi di in gr _col(41) "Min weight fraction/leaf  = " in ye "`min_weight_fraction_leaf'"
noi di in gr "Split criterion     = " in ye "`criterion'" _continue
noi di in gr _col(41) "Min impurity decrease     = " in ye "`min_impurity_decrease'"
noi di " "
noi di in gr "{ul:Output}"
noi di in gr "Prediction: " in ye "`prediction_di'"
if "`type'"=="regress" {
	noi di in gr "Training RMSE       = " in ye `is_rmse'
	*noi di in gr "Training MAE        = " in ye `is_mae'
}
if "`type'"=="classify" {
	noi di in gr "Training accuracy   = " in ye `e(training_accuracy)'
}
if "`type'"=="regress" & `nonempty_test'==1 {
	noi di in gr "Validation RMSE     = " in ye `os_rmse'
	*noi di in gr "Validation MAE      = " in ye `os_mae'
}
if "`type'"=="classify" & `nonempty_test'==1 {
	noi di in gr "Validation accuracy = " in ye `e(test_accuracy)'
}
noi di " "
noi di in gr "Type {help pytree:help pytree} to access the pytree documentation."
noi di "Type {stata pytree_display:pytree_display} to display the decision tree."
noi di "{hline 80}"

	
*-------------------------------------------------------------------------------
* Clean up before ending Stata script
*-------------------------------------------------------------------------------

* Keep the index and prediction, then merge onto original data
keep `index' `prediction'
tempfile t1
qui save `t1'
restore
qui merge 1:1 `index' using `t1', nogen
drop `index'

* If y needed encoding, decode
* XX this is inefficient
if "`needs_encoding'"=="yes" {
	tempvar encode1
	encode `yvar', gen(`encode1')
	label values `prediction' `encode1'
	decode `prediction', gen(`prediction'_2)
	drop `prediction'
	rename `prediction'_2 `prediction'
}

* Return stuff to e class
*ereturn matrix importance = temp1e
ereturn local predict "pytree_p"
global features "`xvars'"

ereturn local pytree_display "pytree_d"

ereturn local insample_rmse `is_rmse'
ereturn local outsample_rmse `os_rmse'


end

*===============================================================================
* Python helper functions
*===============================================================================

version 16.0
python:

#-------------------------------------------------------------------------------
# Import required packages and attempt to install w/ Pip if that fails
#-------------------------------------------------------------------------------

# Import required Python modules (pandas, scikit-learn, sfi)
from pandas import DataFrame
from sklearn.tree import DecisionTreeClassifier,DecisionTreeRegressor
from sfi import Data,Matrix,Scalar
from sklearn import metrics
import numpy as np

# XX test passing object to main
import __main__

# Set random seed
import random
random.seed(50)

#-------------------------------------------------------------------------------
# Define Python function: run_random_forest
#-------------------------------------------------------------------------------

def run_decision_tree(type,
					 vars,
					 criterion,
					 max_depth,
					 min_samples_split,
					 min_samples_leaf,
					 min_weight_fraction_leaf,
					 max_features,
					 max_leaf_nodes,
					 min_impurity_decrease,
					 random_state,
					 class_weight,
					 prediction,
					 training,
					 importance,
					 nonempty_test):

	#-----------------------------------
	# Load data from Stata into Python
	#-----------------------------------
	
	# Load into Pandas data frame
	df = DataFrame(Data.get(vars))
	colnames = []
	for var in vars.split():
		 colnames.append(var)
	df.columns = colnames

	# Split training data and test data into separate data frames
	df_train, df_test = df[df[training]==1], df[df[training]==0]

	# Create list of feature names
	features = df.columns[2:]
	y        = df.columns[1]
	
	#-----------------------------------
	# Run decision tree model model
	#-----------------------------------
	
    # Initialize decision tree regressor (if model type is regress)
	if type=="regress":
		model = DecisionTreeRegressor(criterion=criterion, 
								  max_depth=max_depth,
								  min_samples_split=min_samples_split, 
								  min_samples_leaf=min_samples_leaf, 
								  min_weight_fraction_leaf=min_weight_fraction_leaf, 
								  max_features=max_features, 
								  max_leaf_nodes=max_leaf_nodes, 
								  min_impurity_decrease=min_impurity_decrease, 
								  random_state=random_state)

	# Initialize decision tree classifier (if model type is classify)
	if type=="classify":
		model = DecisionTreeClassifier(criterion=criterion, 
								   max_depth=max_depth, 
								   min_samples_split=min_samples_split, 
								   min_samples_leaf=min_samples_leaf, 
								   min_weight_fraction_leaf=min_weight_fraction_leaf, 
								   max_features=max_features, 
								   max_leaf_nodes=max_leaf_nodes, 
								   min_impurity_decrease=min_impurity_decrease, 
								   random_state=random_state)

    # Run decision tree model on training data
	tree = model.fit(df_train[features], df_train[y])
	
	# Pass random forest model back to __main__ namespace to interact w/ later
	__main__.model_object = model
	
	# Pass tree back for display later
	__main__.tree = tree
	
	# Pass feature names back for access later
	__main__.features = features
	
	# XX MAKE THESE LINES TRIGGER ONLY IF SAVE_PREDICTIONS USED
	# Generate predictions (on both training and test data)
	if prediction!="":
		pred    = model.predict(df[features])
		Data.addVarFloat(prediction)
		Data.store(prediction,None,pred)
		
	# Get in-sample prediction and in-sample prediction accuracy
	pred_insample = model.predict(df_train[features])
	y_insample = df_train[y]
	
	
	# If regression: get in sample (training sample) mae, rmse
	if type=="regress":
		insample_mae = metrics.mean_absolute_error(y_insample, pred_insample)
		insample_mse = metrics.mean_squared_error(y_insample, pred_insample)
		insample_rmse = np.sqrt(insample_mse)
		Scalar.setValue("e(training_mae)", insample_mae, vtype='visible')
		Scalar.setValue("e(training_rmse)", insample_rmse, vtype='visible')
	
	
	# If classify: get in sample (training sample) accuracy
	if type=="classify":
		insample_accuracy = metrics.accuracy_score(y_insample, pred_insample)
		Scalar.setValue("e(training_accuracy)", insample_accuracy, vtype='visible')
		
	# If nonempty test sample, get out of sample stats
	if type=="regress" and nonempty_test==1:
		# print(nonempty_test)
		pred_outsample = model.predict(df_test[features])
		y_outsample = df_test[y]
		outsample_mae = metrics.mean_absolute_error(y_outsample, pred_outsample)
		outsample_mse = metrics.mean_squared_error(y_outsample, pred_outsample)
		outsample_rmse = np.sqrt(outsample_mse)
		Scalar.setValue("e(test_mae)", outsample_mae, vtype='visible')
		Scalar.setValue("e(test_rmse)", outsample_rmse, vtype='visible')
	
	if type=="classify" and nonempty_test==1:
		pred_outsample = model.predict(df_test[features])
		y_outsample = df_test[y]
		outsample_accuracy = metrics.accuracy_score(y_outsample, pred_outsample)
		Scalar.setValue("e(test_accuracy)", outsample_accuracy, vtype='visible')

	
	# If applicable, display feature importance
	feature_importances = DataFrame(model.feature_importances_,
										index = features,
										columns=['importance']).sort_values('importance', ascending=False)
	z = feature_importances.shape
	importance = list(model.feature_importances_)
	Matrix.create("importance", z[0], z[1], -1)
	Matrix.setColNames("importance",['importance'])
	Matrix.setRowNames("importance",list(features.values))
	# print(importance[0])
	for i in range(z[0]):
		# print(i)
		Matrix.storeAt("importance",i,0,importance[i])


def get_predictions(vars, prediction):

	# Import random forest object data from main namespace
	from __main__ import model_object as model
	
	# Load data into Pandas data frame
	df = DataFrame(Data.get(vars))
	colnames = []
	for var in vars.split():
		 colnames.append(var)
	df.columns = colnames
	
	# Create list of feature names
	features = df.columns[2:]
	
	# Generate predictions (on both training and test data)
	pred    = model.predict(df[features])
	
	# Export predictions back to Stata
   	Data.addVarFloat(prediction)
	Data.store(prediction,None,pred)
	
	
end
