
pyforest
=================================

[Overview](#overview)
| [Installation](#installation)
| [Usage](#usage)
| [Benchmarks](#benchmarks)
| [To-Do](#todo)
| [Acknowledgements](#acknowledgements)
| [License](#license)

Regression and classification with random forests in Stata

`version 0.14 10jan2020`


Overview
---------------------------------

pyforest is an implementation of the random forest algorithm in Stata 16 for classification and regression. It is essentially a wrapper around the popular scikit-learn library in Python, making use of the Stata Function Interface to pass data to and from Python from within the Stata window. 


Prequisites
---------------------------------

pyforest requires Stata version 16 or higher, since it relies on the Python integration introduced in Stata 16.0. It also requires Python 3.x and the scikit-learn library. If you have not installed Python or scikit-learn, I would highly recommend starting with the [Anaconda distribution](https://docs.anaconda.com/anaconda).


Installation
---------------------------------

There are two options for installing pyforest.

1. The most recent version can be installed from Github with the following Stata command:

```stata
net install pyforest, from(https://raw.githubusercontent.com/mdroste/stata-pyforest/master/)
```

2. A ZIP containing pyforest.ado and pyforest.sthlp can be downloaded from Github and manually placed on the user's adopath.


Usage
---------------------------------

Basic usage of pyforest is pretty simple. The syntax looks similar to -regress-. Optional arguments share exactly the same syntax as [scikit-learn.ensemble.RandomForestClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html) and [scikit-learn.ensemble.RandomForestRegressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html).

Here is a quick example demonstrating how to use pyforest for classification:

```stata
* load dataset of flowers
use http://www.stata-press.com/data/r10/iris.dta, clear

* mark approx half of the dataset for estimation
gen train = runiform()<0.5

* run random forest classification, save predictions as predicted_iris
pyforest iris seplen sepwid petlen petwid, type(classify) training(train) prediction(predicted_iris)
```

Here is a quick example demonstrating how to use pyforest for regression:

```stata
* load dataset of cars
sysuse auto, clear

* mark approx 30% of obs for estimation
gen train = runiform()<0.3

* run random forest regression, save predictions as predicted_price
pyforest price mpg trunk weight, type(regress) training(train) prediction(predicted_price)

* alternatively, if you prefer more stata-like syntax, you can subset to the training data with -if- and use post-estimation predict
pyforest price mpg trunk weight if train==1, type(regress)
predict predicted_price_v2
```

(Incomplete) internal documentation can be found within Stata. This documentation is still a work in progress:
```stata
help pyforest
```

Finally, since the option syntax in this package is inherited from scikit-learn, the documentation for the scikit methods sklearn.ensemble.randomForestClassification and sklearn.ensemble.randomForestRegression may be useful. 

  
Todo
---------------------------------

The following items will be addressed soon:

- [ ] Finish off this readme.md and the help file
- [ ] Proide some benchmarking
- [ ] Make exception handling more robust
- [ ] Add support for weights
- [ ] Return some stuff in e()
- [ ] Post-estimation: feature importance
- [ ] Model selection: cross-validation


Acknowledgements
---------------------------------

This program relies on the wonderful Python package scikit-learn.


License
---------------------------------

pyforest is [MIT-licensed](https://github.com/mdroste/stata-pyforest/blob/master/LICENSE).
