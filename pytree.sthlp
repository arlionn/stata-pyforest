{smcl}
{* *! version 0.25 29mar2020}{...}
{viewerjumpto "Syntax" "pytree##syntax"}{...}
{viewerjumpto "Description" "pytree##description"}{...}
{viewerjumpto "Options" "pytree##options"}{...}
{viewerjumpto "Examples" "pytree##examples"}{...}
{viewerjumpto "Author" "pytree##author"}{...}
{viewerjumpto "Acknowledgements" "pytree##acknowledgements"}{...}
{title:Title}
 
{p2colset 5 17 21 2}{...}
{p2col :{hi:pytree} {hline 2}}Decision tree regression and classification with Python and scikit-learn{p_end}
{p2colreset}{...}
 
 
{marker syntax}{title:Syntax}
 
{p 8 15 2}
{cmd:pytree} depvar indepvars {ifin}, type(string) [{cmd:}{it:options}]
                               
 
{synoptset 40 tabbed}{...}
{synopthdr :options}
{synoptline}
 
{syntab :Main}
{synopt :{opt type(string)}}{it:string} may be {bf:regress} or {bf:classify}.{p_end}

{syntab :Training options}
{synopt :{opt training(varname)}}varname is an indicator for the training sample (if unspecified, all observations used){p_end}
 
{syntab :Decision tree options (model hyper-parameters)}
{synopt :{opt criterion(string)}}Criterion for splitting nodes (see details below){p_end}
{synopt :{opt max_depth(#)}}Maximum tree depth{p_end}
{synopt :{opt min_samples_split(#)}}Minimum observations per node{p_end}
{synopt :{opt min_weight_fraction_leaf(#)}}Min fraction at leaf{p_end}
{synopt :{opt max_features(numeric)}}Maximum number of features to consider per tree{p_end}
{synopt :{opt max_leaf_nodes(#)}}Maximum leaf nodes{p_end}
{synopt :{opt min_impurity_decrease(#)}}Propensity to split{p_end}

{syntab :Output options}
{synopt :{opt prediction(newvar)}}Save prediction as {bf: newvar}{p_end}
{synopt :{opt training(newvar)}}Save indicator for training sample as {bf: newvar}{p_end}

{synoptline}
{p 4 6 2}
{opt aweight}s are allowed;
see {help weight}.
{p_end}
 
 
{marker description}{...}
{title:Description}
 
{pstd}
{opt pytree} performs regression or classification with decision trees. 

{pstd} In particular, {opt pytree} implements decision trees using Python's scikit-learn module; specifically, the decisionTreeClassifier decisionTreeRegression methods.

{pstd} Note that {opt pytree} relies on the Python integration functionality introduced with Stata 16. Therefore, users will need Stata 16, Python (preferably 3.x), and the scikit-learn library installed in order to run this ado-file.

 
 
{marker options}{...}
{title:Options}
 
{dlgtab:Main}
 
{phang}
{opth type(string)} declares whether this is a regression or classification problem. In general, type(classify) is more appropriate when the dependent variable is categorical, and type(regression) is more appropriate when the dependent variable is continuous.
 
{dlgtab:Training data options}

{phang}
{opt training(varname)} identifies an indicator variable in the current dataset that is equal to 1 when an observation should be used for training and 0 otherwise.

{dlgtab:Decision tree options}
 
{phang}

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

{dlgtab:Save Output}
 
{phang}
{opt prediction(newvar)} specifies a new variable name for storing predicted outcomes. pytree does not save predictions by default, though they can be obtained post-estimation by using the syntax "predict (newvarname)".

{phang}
{opt training(var)} specifies a variable that denotes whether an observation is in the training dataset (var==1) or the test dataset (var==0). By default, the entire dataset is used for training.

{marker examples}{...}
{title:Examples}
 
{pstd}See the Github page.{p_end}

{pstd}Example 1: Classification with decision trees, saivng predictions as a new variable called iris_prediction{p_end}
{phang2}. {stata sysuse iris, clear}{p_end}
{phang2}. {stata pytree iris seplen sepwid petlen petwid, type(classify) save_prediction(iris_predicted)}{p_end}

{pstd}Example 2: Classification with decision trees, evaluating on a random subset of the data{p_end}
{phang2}. {stata sysuse iris, clear}{p_end}
{phang2}. {stata pytree iris seplen sepwid petlen petwid, type(classify) training(training_flag) save_prediction(iris_predicted) max_depth(2)}{p_end}
 
{marker author}{...}
{title:Author}
 
{pstd}Michael Droste{p_end}
{pstd}mdroste@fas.harvard.edu{p_end}
 
 
 
{marker acknowledgements}{...}
{title:Acknowledgements}

{pstd}This program owes a lot to the wonderful scikit-learn library in Python.
{pstd}Read more about scikit-learn here: https://scikit-learn.org


