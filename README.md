
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

`version 0.19 11jan2020`


Overview
---------------------------------

pyforest is an implementation of the random forest algorithm in Stata 16 for classification and regression. It is essentially a wrapper around the popular [scikit-learn](https://scikit-learn.org/) module for Python. It enables Stata users to quickly and flexibly estimate random forest models within Stata.


Prequisites
---------------------------------

pyforest requires Stata version 16 or higher, since it relies on the [native Python integration](https://www.stata.com/new-in-stata/python-integration/) introduced in Stata 16.0. 

pyforest also requires Python 2.7+ and a few Python modules, namely [scikit-learn](https://scikit-learn.org/), [pandas](https://pandas.pydata.org/), and [NumPy](https://numpy.org/)). This repository includes an ado-file, pyforest_setup, that will attempt to install these modules automatically. Alternatively, users can download and use [Anaconda](https://www.anaconda.com/distribution/#download-section), which contains all of these modules (and many more) out of the box.


Installation
---------------------------------

There are two options for installing pyforest.

1. Use the following Stata command to install pyforest directly from Stata:

```stata
net install pyforest, from(https://raw.githubusercontent.com/mdroste/stata-pyforest/master/) replace
```

2. Download the files in this repository and place them on your Stata ado-path (that is, any directory listed when you use the Stata command -adopath-). 


Usage
---------------------------------

Using pyforest is simple, and the syntax is very similar to regression estimation commands widely used in Stata. Optional arguments share exactly the same syntax as [scikit-learn.ensemble.RandomForestClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html) and [scikit-learn.ensemble.RandomForestRegressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html). The user must declare an option, type(), to say whether the random forest model is for classification (i.e. categorical y) or regression (i.e. ordinal y).

Here is a quick example demonstrating how to use pyforest for classification:

```stata
* Load dataset of flowers
use http://www.stata-press.com/data/r10/iris.dta, clear

* Train the model on approx. half of the dataset, choosing random observations
gen train = runiform()<0.5

* Run a random forest classification model on the training sample and obtain predictions with post-estimation 'predict' command
pyforest iris seplen sepwid petlen petwid, type(classify) training(train)
predict iris_predicted

* We can also use 'if' to specify the training sample, although then pyforest will not give you out-of-sample fit statistics
pyforest iris seplen sepwid petlen petwid if train==1, type(classify)

* If I do not specify training(), Stata will use all available observations (that satisfy if/in condition) for training:
pyforest iris seplen sepwid petlen petwid, type(classify)
```

Here is a quick example demonstrating how to use pyforest for regression:

```stata
* Load dataset of cars
sysuse auto, clear

* Train the model on observations with foreign==0
gen train = foreign==0

* Run random forest regression, save predictions as predicted_price 
pyforest price mpg trunk weight, type(regress) training(train) prediction(price_predicted)


Internal documentation for the program can be found within Stata:
```stata
help pyforest
```

This repository includes an example do-file, pyforest_examples.do, that walks through many more examples. 

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

This program relies primarily on scikit-learn.

Thanks to 


License
---------------------------------

pyforest is [MIT-licensed](https://github.com/mdroste/stata-pyforest/blob/master/LICENSE).
