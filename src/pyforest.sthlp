{smcl}
{* *! version 0.20 14jan2020}{...}
{viewerjumpto "Syntax" "pyforest##syntax"}{...}
{viewerjumpto "Description" "pyforest##description"}{...}
{viewerjumpto "Options" "pyforest##options"}{...}
{viewerjumpto "Examples" "pyforest##examples"}{...}
{viewerjumpto "Author" "pyforest##author"}{...}
{viewerjumpto "Acknowledgements" "pyforest##acknowledgements"}{...}
{title:Title}
 
{p2colset 5 17 21 2}{...}
{p2col :{hi:pyforest} {hline 2}}Random forest regression and classification with Python and scikit-learn{p_end}
{p2colreset}{...}
 
 
{marker syntax}{title:Syntax}
 
{p 8 15 2}
{cmd:pyforest} depvar indepvars {ifin}, type(string) [{cmd:}{it:options}]
                               
 
{synoptset 40 tabbed}{...}
{synopthdr :options}
{synoptline}
 
{syntab :Main}
{synopt :{opt type(string)}}{it:string} may be {bf:regress} or {bf:classify}.{p_end}

{syntab :Random forest options}
{synopt :{opt n_estimators(#)}}Number of trees{p_end}
{synopt :{opt criterion(string)}}Criterion for splitting nodes (see details below){p_end}
{synopt :{opt max_depth(#)}}Maximum tree depth{p_end}
{synopt :{opt min_samples_split(#)}}Minimum observations per node{p_end}
{synopt :{opt min_weight_fraction_leaf(#)}}Min fraction at leaf{p_end}
{synopt :{opt max_features(numeric)}}Maximum number of features to consider per tree{p_end}
{synopt :{opt max_leaf_nodes(#)}}Maximum leaf nodes{p_end}
{synopt :{opt min_impurity_decrease(#)}}Propensity to split{p_end}
{synopt :{opt nobootstrap}}Do not bootstrap observations for each tree{p_end}

{syntab :Training options}
{synopt :{opt training(varname)}}varname is an indicator for the training sample{p_end}

{syntab :Output options}
{synopt :{opt prediction(newvar)}}Save prediction as {bf: newvar}{p_end}

{syntab :Miscellaneous options}
{synopt :{opt n_jobs(#)}}Number of cores to use when processing data{p_end}

{synoptline}
{p 4 6 2}
{p_end}
 
 
{marker description}{...}
{title:Description}
 
{pstd}
{opt pyforest} performs regression or classification with the random forest algorithm described by Breiman et al (2001). 

{pstd} In particular, {opt pyforest} implemenets the random forest algorithm as a wrapper around the Python modules sklearn.ensemble randomForestClassifier and sklearn.ensemble.randomForestRegression, distributed as components of the scikit-learn Python library.

{pstd} {opt pyforest} relies critically on the Python integration functionality introduced with Stata 16. Therefore, users will need Stata 16, Python (preferably 3.x), and the scikit-learn library installed in order to run.

 
 
{marker options}{...}
{title:Options}
 
{dlgtab:Main}
 
{phang}
{opth type(string)} declares whether this is a regression or classification problem. In general, type(classify) is more appropriate when the dependent variable is categorical, and type(regression) is more appropriate when the dependent variable is continuous.

{dlgtab:Random forest options}
 
{phang}
{opt n_estimators(#)} determines the number of trees used. In general, more is better. The default is n_estimators(100).

{phang}
{opt criterion(string)} determines the function used to measure the quality of a proposed split. Valid options for criterion() depend on whether the task is a classification task or a regression task. If type(regress) is specified, valid options are mse (default) and mae. If type(classify) is specified, valid options are gini (default) and entropy. 

{phang}
{opt max_depth(#)} specifies the maximum tree depth. By default, this is None.

{phang}
{opt min_samples_split(#)} specifies the minimum number of observations required to consider splitting an internal node of a tree. By default, this is 2.

{phang}
{opt min_samples_leaf(#)} specifies the minimum number of observations required at each 'leaf' node of a tree. By default, this is 1.

{phang}
{opt min_weight_fraction_leaf(#)} specifies the minimum weighted fraction of the sum of weights required at each leaf node. When weights are not specified, this is simply the minimum fraction of observations required at each leaf node. By default, this is 0.

{phang}
{opt max_features(string)} specifies the number of features to consider when looking for the best split. By default, this is equal to the number of features (aka independent variables). Other options are max_features(sqrt) (the square root of the number of features), max_features(log2) (the base-2 logarithm of the number of features), an integer, or a float. If a non-integer is specified, then int(max_features,number of features) are considered at each split.

{phang}
{opt max_leaf_nodes(#)} Grow trees with max_leaf_nodes in best-first fashion, where best is defined in terms of relative reduction in impurity. By default, an unlimited number of leaf nodes. 

{phang}
{opt min_impurity_decrease(#)} determines the threshold such tha a node is split if it induces a decrease in impurity criterion greater than or equal to this value. By default, this is 0. 

{phang}
{opt nobootstrap} determines whether bootstrapped samples are used when building trees. If this option is specified, no bootstrapped samples are used, i.e. the whole dataset is used for each tree. By default, each tree uses data that is bootstrapped with replacement (same # of obs) from the original data.

{dlgtab:Training data options}

{phang}
{opt training(varname)} identifies an indicator variable in the current dataset that is equal to 1 when an observation should be used for training and 0 otherwise. 


{dlgtab:Save Output}
 
{phang}
{opt prediction(newvar)} specifies a new variable name for storing predicted outcomes. pyforest does not produce save predictions by default.
{opt training(varname)} species the variable name for an indicator denoting whether an observation is in the training data or not. By default, _rf_prediction is used.

{phang}
{opt training(newvar)} specifies a new variable name for storing an indicator variable for whether an observation is in the training dataset.  If training_identifier() is used, this option does nothing, since training_identifier() points to a pre-existing variable.

{marker examples}{...}
{title:Examples}
 
{pstd}See the Github page.{p_end}

{pstd}Example 1: Classification with random forests, saivng predictions as a new variable called iris_prediction{p_end}
{phang2} Load data{p_end}
{phang2}. {stata webuse iris, clear}{p_end}
{phang2} Run random forest classifier{p_end}
{phang2}. {stata pyforest iris seplen sepwid petlen petwid, type(classify)}{p_end}
{phang2} Save predictions in a variable called iris_hat{p_end}
{phang2}. {stata predict iris_hat}{p_end}

{pstd}Example 2: Classification with random forests, evaluating on a random subset of the data{p_end}
{phang2} Load data{p_end}
{phang2}. {stata webuse iris, clear}{p_end}
{phang2} Train on about 3/4 of obs{p_end}
{phang2}. {stata gen train_flag = runiform()<0.75}{p_end}
{phang2} Run random forest classifier, training on training sample{p_end}
{phang2}. {stata pyforest iris seplen sepwid petlen petwid if train_flag==1, type(classify)}{p_end}
{phang2} Alternative syntax for the above: we can use training() and obtain test sample RMSE in one step{p_end}
{phang2}. {stata pyforest iris seplen sepwid petlen petwid, type(classify) training(train_flag)}{p_end}
{phang2} Save predictions in a variable called iris_hat{p_end}
{phang2}. {stata predict iris_hat}{p_end}
 
{marker author}{...}
{title:Author}
 
{pstd}Michael Droste{p_end}
{pstd}mdroste@fas.harvard.edu{p_end}
 
 
 
{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}This program owes a lot to the wonderful scikit-learn library in Python.
{pstd}Read more about scikit-learn here: https://scikit-learn.org


