
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

`version 0.1 16jul2019`


Overview
---------------------------------

pyforest is an implementation of the random forest algorithm in Stata 16 for classification and regression. It is essentially a wrapper around the popular scikit-learn library in Python, making use of the Stata Function Interface to pass data to and from Python from within the Stata window. 


Prequisites
---------------------------------

pyforest requires Stata version 16 or higher, since it relies on the Python integration introduced in Stata 16.0. It also requires Python 3.x and the scikit-learn library. For more information on installing Python or scikit-learn, refer to their websites here:


Installation
---------------------------------

There are two options for installing pyforest.

1. The most recent version can be installed from Github with the following Stata command:

```stata
net install pyforest, from(https://raw.githubusercontent.com/mdroste/stata-pyforest/master/)
```

2. A ZIP containing the program can be downloaded and manually placed on the user's adopath from Github.


Usage
---------------------------------

Basic usage of pyforest can be performed out of the box. The following command will predict the variable price using mpg, weight, and headroom and save predictions as the variable price_hat_rf, using only observations where train = 1. 

```stata
sysuse auto, clear
gen train = runiform()<0.5
pyforest price mpg weight headroom, type(regress) save_predictions(price_hat_rf) training_identifier(train)
```

More on this soon. See the help file in Stata.

  
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
