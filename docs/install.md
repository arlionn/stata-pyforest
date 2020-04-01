
Installing pyforest prerequisites
=================================

Overview
---------------------------------

pyforest is a Stata plugin for decision trees and random forests. It relies on Stata 16's built-in Stata functionality and a few Python libraries. In particular, pyforest requires the popular Python packages scikit-learn and pandas (along with all of their prerequisites).

The easiest way to install the Python prerequisites is to install Anaconda. Anaconda is a distribution of Python that includes all of the necessary prerequisites. You can install Anaconda even if you already have one or more Python installations on your computer.

Alternatively, you can use any Python installation if you have scikit-learn and pandas installed.


Installation with Anaconda
---------------------------------


1. Download the Stata component of pyforest by typing the following Stata command into the Stata window:

```stata
net install pyforest, from(https://raw.githubusercontent.com/mdroste/stata-pyforest/master/) replace
```

2. Download the most recent verison of Anaconda with Python 3 from [Anaconda's website](https://www.anaconda.com/distribution/#download-section).
   Follow the directions on the installer. Install for 'Just me' rather than 'All users'. 
   *Take note of the install path, as shown in the figure below.*
   *If prompted, choose to make Anaconda your computer's "default" installation of Python*.

<p align="center"><img src="https://raw.githubusercontent.com/mdroste/stata-pyforest/master/docs/images/fig1.png"></p>

3. Close any open Stata windows you might have, and then open a new one. Type "python query" to see if Stata automatically recognizes your Python installation.

<p align="center"><img src="https://raw.githubusercontent.com/mdroste/stata-pyforest/master/docs/images/fig2.png"></p>

4. If your Stata window looks like the screenshot above, then proceed to step 5. Otherwise, you will need to tell Stata where your Anaconda installation is with the "set python_exec" option.

<p align="center"><img src="https://raw.githubusercontent.com/mdroste/stata-pyforest/master/docs/images/fig2b.png"></p>

5. Run the program pyforest_setup to make sure you have all the prerequisite Python libraries. By default, these all come with Anaconda.

<p align="center"><img src="https://raw.githubusercontent.com/mdroste/stata-pyforest/master/docs/images/fig4.png"></p>



Installation with Existing Python Installation
---------------------------------

If you already have Python installed, it should be straightforward to get running - follow the same guide as above, but starting from step 3.

