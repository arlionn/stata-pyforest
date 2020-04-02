
Installing pyforest prerequisites
=================================

Overview
---------------------------------

pyforest is a Stata plugin for decision trees and random forests. It relies on Stata 16's built-in Stata functionality and a few Python libraries. In particular, pyforest requires the popular Python packages scikit-learn and pandas (along with all of their prerequisites).

The easiest way to install the Python prerequisites is to install Anaconda. Anaconda is a distribution of Python that includes all of the necessary prerequisites. You can install Anaconda even if you already have one or more Python installations on your computer.

Alternatively, you can use any Python installation if you have scikit-learn and pandas installed.


Windows: Installation with Anaconda
---------------------------------


1. Download the Stata component of pyforest by typing the following Stata command into the Stata window:

```stata
net install pyforest, from(https://raw.githubusercontent.com/mdroste/stata-pyforest/master/) replace
```

2. Download the most recent verison of Anaconda with Python 3 from [Anaconda's website](https://www.anaconda.com/distribution/#download-section).
   Follow the directions on the installer. Install for 'Just me' rather than 'All users'. 
   *If you're on Windows, take note of the install path, as shown in the figure below.*
   *If prompted, choose to make Anaconda your computer's "default" installation of Python*.

<p align="center"><img src="https://raw.githubusercontent.com/mdroste/stata-pyforest/master/docs/images/fig1.png"></p>

3. Close any open Stata windows you might have, and then open a new one. Type "python query" to see if Stata automatically recognizes your Python installation.

<p align="center"><img src="https://raw.githubusercontent.com/mdroste/stata-pyforest/master/docs/images/fig2.png"></p>

4. If your Stata window looks like the screenshot above, with a file path that includes the word Anaconda, then proceed to step 5. Otherwise, you will need to tell Stata where your Anaconda installation is with the "set python_exec" option. If you are on a Mac, refer to the "Common Issue with Mac Installations" below. 

If you are on Windows, make sure to write down the path (you can open the Anaconda installer again if you forgot it) Anaconda installed to, and then use python_exec like so:

<p align="center"><img src="https://raw.githubusercontent.com/mdroste/stata-pyforest/master/docs/images/fig2b.png"></p>

If you are on Mac, the path to your Anaconda installation will look a bit different from the Windows path above. It will be of the form (some directory here)/anaconda3/bin/python3. For more on this, see the section "Note for Mac Installations" below.

5. Run the program pyforest_setup to make sure you have all the prerequisite Python libraries. By default, these all come with Anaconda.

<p align="center"><img src="https://raw.githubusercontent.com/mdroste/stata-pyforest/master/docs/images/fig4.png"></p>

Mac: Installation with Python
---------------------------------

There are a few compatibility issues with some versions of Mac OSX and Anaconda, the Python distribution we recommend for Windows (see 'Problems with Anaconda on Mac' below). 

Therefore, if you are on a Mac, I recommend you download the most recent official release of Python from (this link)[https://www.python.org/downloads/]. Note the installation path when you go through the installer. Then follow steps 1, 3, 4, and 5 as outlined above in the Windows installation, making sure that the version of Python used by Stata matches the location of this Python installation.

Installation with Existing Python Installation
---------------------------------

If you already have Python installed, it should be straightforward to get running - follow the same guide as above, but starting from step 3.


Note for Mac Installations with Anaconda
---------------------------------

Some (but not all) versions of Mac OSX install Anaconda to a path like "/Users/(username)/opt/anaconda3". Stata will not be able to recognize this path automatically in step 3. Fortunately, there is an easy fix! Simply type the following into the Stata terminal:
```stata
set python_exec "/Users/(username)/opt/anaconda3/bin/python3", perm
```

Once you've typed that once, you don't need to do it again - Stata will remember this path from now on.

If you're on a Mac and not sure where Anaconda installed, simply run the installer again - it will eventually throw an error telling you the path of the installation, which you can use in the "set python_exec" command above.



Problems with Anaconda on Mac
---------------------------------

A small number of Mac users are encountering issues with Anaconda. Sometimes, running pyforest/pytree leads a large stream of errors relating to importing libraries. This is a (bug)[https://www.statalist.org/forums/forum/general-stata-discussion/general/1537891-failure-of-anaconda-miniconda-python-in-stata-16-1-for-macos] in Stata with Anaconda that seems to be difficult to fix. Instead, you should download the most recent version of Python from the official website (click here)[https://www.python.org/downloads/] and then follow the instructions 3-5 above, taking care to set your python path in step (4) to the location of this version of Python, and then running pyforest_setup.