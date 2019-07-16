*===============================================================================
* File:    benchmark_pyforest.do
* Purpose: Demonstrates usage for the Stata 16 package pyforest, which provides
*          a Stata wrapper for the Python implementation of random forest 
*          regression and classification in scikit-learn
* Author:  Michael Drsote
* Info:    https://github.com/mdroste/stata-pyforest
*===============================================================================

* preliminary - install latest version of pyforest
cap program drop pyforest
net install pyforest, from("https://raw.githubusercontent.com/mdroste/stata-pyforest/master/") force replace

*-------------------------------------------------------------------------------
* Basic usage examples
*-------------------------------------------------------------------------------

* RF classification: numeric (but discrete) y variable
sysuse auto, clear
pyforest foreign trunk mpg price, type(classify) 

* RF classification: string y variable
sysuse auto, clear
gen foreign_str = "Foreign"
replace foreign_str = "Domestic" if foreign==0
pyforest foreign_str trunk mpg price, type(classify) 

* RF regression: continuous y variable
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) 

* RF regression: use mae rather than mse as node splitting criterion
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) criterion(mae)

*-------------------------------------------------------------------------------
* Benchmark functionality
*-------------------------------------------------------------------------------

cd "C:\Users\Mike\Documents\GitHub\stata-pyforest"
cap program drop pyforest

* basic classification
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress)

* option: n_estimators()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) n_estimators(50)

* option: criterion()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) criterion("entropy")

* option: max_depth()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) max_depth(3)

* option: min_samples_split()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) min_samples_split(3)

* option: min_samples_leaf()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) min_samples_leaf(2)

* option: min_weight_fraction_leaf()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) min_weight_fraction_leaf(0.1)

* option: max_features()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) max_features(log2)
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) max_features(2)

* option: max_leaf_nodes()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) max_leaf_nodes(5)

* option: min_impurity_decrease()
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) min_impurity_decrease(0.1)

* option: nobootstrap
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) nobootstrap

* option: n_jobs
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) n_jobs(3)

* option: random_state
sysuse auto, clear
pyforest price mpg foreign trunk, type(regress) random_state(123)
