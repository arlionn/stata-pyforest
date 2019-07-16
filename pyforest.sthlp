{smcl}
{* *! version 0.1  16jul2019}{...}
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
{cmd:pyforest} depvar indepvars {ifin} {weight}, type(string) [{cmd:}{it:options}]
                               
 
{synoptset 40 tabbed}{...}
{synopthdr :options}
{synoptline}
 
{syntab :Main}
{synopt :{opt type(string)}}{it:string} may be {bf:regress} or {bf:classify}.{p_end}

{syntab :Training options}
{synopt :{opt frac_training(numeric)}}fraction of observations to place in training dataset{p_end}
{synopt :{opt training_identifier(varname)}}Use varname as indicator for training sample{p_end}
{synopt :{opt training_stratify(varname)}}Stratify random sample according to varname{p_end}
 
{syntab :Random forest options}
{synopt :{opt n_estimators(integer)}}Number of trees{p_end}
{synopt :{opt criterion(string)}}Criterion for splitting nodes (see details below){p_end}
{synopt :{opt max_depth(numeric)}}Maximum tree depth{p_end}
{synopt :{opt min_samples_split(numeric)}}Minimum observations per node{p_end}
{synopt :{opt min_weight_fraction_leaf(numeric)}}xx{p_end}
{synopt :{opt max_features(numeric)}}Maximum number of features to consider per tree{p_end}
{synopt :{opt max_leaf_nodes(numeric)}}Maximum leaf nodes{p_end}
{synopt :{opt min_impurity_decrease(numeric)}}Propensity to split{p_end}
{synopt :{opt nobootstrap}}Do not bootstrap observations for each tree{p_end}
{synopt :{opt oob_score}}Whether to use out-of-bag obs. to est. generalization accuracy{p_end}
{synopt :{opt verbose}}Controls verbosity of output{p_end}
{synopt :{opt class_weight}}Not yet implemented{p_end}

{syntab :Output options}
{synopt :{opt save_predictions(varname)}}Saves predictions to {bf: varname}{p_end}

{syntab :Miscellaneous options}
{synopt :{opt n_jobs}}Number of cores to use when processing data{p_end}

{synoptline}
{p 4 6 2}
{opt aweight}s are allowed;
see {help weight}.
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
{opt n_estimators(integer)} determines the number of trees used. In general, a higher number is better. The default is n_estimators(100).

{phang}
{opt criterion(string)} determines the function used to measure the quality of a proposed split. Valid options for criterion() depend on whether the task is a classification task or a regression task. If type(regress) is specified, valid options are mse (default) and mae. If type(classify) is specified, valid options are gini (default) and entropy. 

{phang}
{opt max_depth(integer)} specifies the maximum tree depth. By default, this is None, meaning this constraint never binds.

{phang}
{opt min_samples_split(integer)} specifies the minimum number of observations required to consider splitting an internal node of a tree. By default, this is 2.

{phang}
{opt min_samples_leaf(integer)} specifies the minimum number of observations required at each 'leaf' node of a tree. By default, this is 1.

{phang}
{opt min_weight_fraction_leaf(integer)} specifies the minimum weighted fraction of the sum of weights required at each leaf node. When weights are not specified, this is simply the minimum fraction of observations required at each leaf node. By default, this is 0.

{phang}
{opt max_features(string)} specifies the number of features to consider when looking for the best split. By default, this is equal to the number of features (aka independent variables). Other options are max_features(sqrt) (the square root of the number of features), max_features(log2) (the base-2 logarithm of the number of features), an integer, or a float. If a non-integer is specified, then int(max_features,number of features) are considered at each split.

{phang}
{opt max_leaf_nodes(int)} Grow trees with max_leaf_nodes in best-first fashion, where best is defined in terms of relative reduction in impurity. By default, an unlimited number of leaf nodes. 

{phang}
{opt min_impurity_decrease(float)} determines the threshold such tha a node is split if it induces a decrease in impurity criterion greater than or equal to this value. By default, this is 0. 

{phang}
{opt nobootstrap} determines whether bootstrapped samples are used when building trees. If this option is specified, no bootstrapped samples are used, i.e. the whole dataset is used for each tree. By default, bootstrapped samples are used.

{dlgtab:Save Output}
 
{phang}
{opt save(filename)} saves the output dataset to a dataset specified by {it:filename}. If a full file path is not provided, the working directory used. If no file extension is specified, .dta is assumed.

{marker examples}{...}
{title:Examples}
 
{pstd}See the Github page.{p_end}
 
{marker author}{...}
{title:Author}
 
{pstd}Michael Droste{p_end}
{pstd}mdroste@fas.harvard.edu{p_end}
 
 
 
{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}This program obviously owes a lot to the wonderful scikit-learn library in Python.
{pstd}Read more about scikit-learn here: https://scikit-learn.org
 
