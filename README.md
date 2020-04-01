
pyforest
=================================

[Overview](#overview)
| [Installation](#installation)
| [Usage](#usage)
| [Benchmarks](#benchmarks)
| [To-Do](#todo)
| [License](#license)

Regression and classification with random forests in Stata

`version 0.3 30mar2020`


Overview
---------------------------------

pyforest is an implementation of the [random forests](https://www.stat.berkeley.edu/~breiman/randomforest2001.pdf) algorithm in Stata 16 for classification and regression. It is essentially a wrapper around the popular [scikit-learn](https://scikit-learn.org/) module for Python. It enables Stata users to quickly and flexibly estimate random forest models directly from Stata.


Prequisites
---------------------------------

pyforest requires Stata version 16 or higher, since it relies on the [native Python integration](https://www.stata.com/new-in-stata/python-integration/) introduced in Stata 16.0. 

pyforest also requires Python 2.7+ (though you should really get Python 3+), [scikit-learn](https://scikit-learn.org), and [pandas](https://pandas.pydata.org/). The easiest way to satisfy all of these prerequisites is by installing [Anaconda](https://www.anaconda.com/distribution/#download-section), which contains all of these modules (and many more) out of the box and should be automatically detected by Stata. ALternatively, this repository includes an additional Stata program, pyforest_setup, that will attempt to install these modules automatically for an existing Python installation. 


Installation
---------------------------------

Installing pyforest is very simple.

1. First, install the Stata code and documentation. You can run the following Stata command to install directly from this GitHub repository:

```stata
net install pyforest, from(https://raw.githubusercontent.com/mdroste/stata-pyforest/master/) replace
```

2. Install Python if you haven't already, and check to make sure Stata can see it with the following Stata command:
```stata
python query
```

If Stata cannot find your Python installation, refer to the [installation guide](docs/installation.md).

3. Make sure that you have the required Python prerequisites installed by running the included Stata program pyforest_setup:

```stata
pyforest_setup
```


Usage
---------------------------------

Using pyforest is simple, since the syntax looks very similar to other commands for model estimaation in Stata. Notably, calls to pyforest must specify an option called type() that specifies whether the model will be used for classification or regression.

Here is a quick example demonstrating how to use pyforest for classification:

```stata
* Load dataset of flowers
use http://www.stata-press.com/data/r10/iris.dta, clear

* Mark about half of the observations as our training sample
generate training_sample = runiform()<0.5

* Run a random forest classification model on the training sample and obtain predictions with post-estimation 'predict' command
pyforest iris seplen sepwid petlen petwid, type(classify) training(training_sample)

* Generate predictions for iris from the model above
predict iris_predicted

* We can also use 'if' to specify the training sample, although then pyforest will not give you out-of-sample fit statistics
pyforest iris seplen sepwid petlen petwid if training_sample==1, type(classify)

* If we do not specify training(), Stata will use all available observations (that satisfy any given if/in condition) 
pyforest iris seplen sepwid petlen petwid, type(classify)
```

Here is a quick example demonstrating how to use pyforest for regression:

```stata
* Load dataset of cars
sysuse auto, clear

* Mark about half of the observations as our training sample (training_sample=1)
generate training_sample = foreign==0

* Run random forest regression, training with training sample identified above, save predictions as price_predicted
pyforest price mpg trunk weight, type(regress) training(training_sample) prediction(price_predicted)
```

Internal documentation for the program can be found within Stata:
```stata
help pyforest
```

This repository includes an example do-file, pyforest_examples.do, that walks through many more examples. 

Finally, since the option syntax in this package is inherited from scikit-learn, the documentation for the scikit methods [sklearn.ensemble.randomForestClassifier](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestClassifier.html) and [sklearn.ensemble.randomForestRegressor](https://scikit-learn.org/stable/modules/generated/sklearn.ensemble.RandomForestRegressor.html) may be useful. 

  
Todo
---------------------------------

The following items will be addressed soon:

- [ ] Add support for weights
- [ ] Post-estimation: feature importance
- [ ] Model selection: cross-validation


License
---------------------------------

pyforest is [MIT-licensed](https://github.com/mdroste/stata-pyforest/blob/master/LICENSE).
