% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/LauraeML.R
\name{LauraeML}
\alias{LauraeML}
\title{Laurae's Machine Learning (Automated modeling, Automated stacking)}
\usage{
LauraeML(data, label, folds, seed = 0, models = NULL, parallelized = NULL,
  optimize = TRUE, no_train = FALSE, logging = NULL, maximize = TRUE,
  features = 0.5, hyperparams = NULL, n_tries = 50, n_iters = 50,
  early_stop = 5, elites = 0.1, feature_smoothing = 1,
  converge_cont = 0.1, converge_disc = 0.1)
}
\arguments{
\item{data}{Type: data.table (mandatory). The data features. \code{dgCMatrix} format support is planned in the future, but not today.}

\item{label}{Type: vector (numeric). The labels. For classes, use a numbering starting from \code{0}.}

\item{folds}{Type: list of numerics. A list containing per element, the observation rows for the folds, which is passed to your modeling functions.}

\item{seed}{Type: numeric. The seed for random number generation. Defaults to \code{0}.}

\item{models}{Type: list of functions. A list of functions, taking each a \code{x} (numeric vector of hyperparameters), \code{y} (numeric vector of features used, where each n-th index refers to the n-th feature, with \code{0} being not selected, and \code{1} being selected), \code{data} (data data.table), \code{folds} (folds list) arguments, transforming the data accordingly depending on the features used, doing validation properly, and returning the cross-validated score to optimize. If you do not want to do cross-validation, you are free to not perform it as no check is performed inside the model functions. You can get the number of the models trained using \code{iters}, which is overwritten in the global environment (and which you should increment in the model functions, if you intend to use it). You can also use \code{hi_score} to get the best score, which is overwritten in the global environment (you can make use of it in your model functions.}

\item{parallelized}{Type: parallel socket cluster (makeCluster or similar). When specified, data is split (in a list) before being fed to the modeling functions (with a list per fold containing first the training data, and second the testing data), at the expense of drastically increasing memory usage. Defaults to \code{NULL}, to lower memory usage. You should set it to if you want pure speed and have enough available RAM to handle the dataset multiple times (\code{length(folds)} times).}

\item{optimize}{Type: boolean. Whether to perform optimization or take everything as is (no optimization of any parameters). Defaults to \code{TRUE}, which means an attempt to optimize hyperparameters and/or features.}

\item{no_train}{Type: boolean. When optimize is \code{FALSE} and your only need is to create the list to be usable later for training all models, set this to \code{TRUE}. Otherwise, never touch it. Defaults to \code{FALSE}.}

\item{logging}{Type: character. The log file output. The logging must be done in the variable \code{mobile$temp_params}. The first column is the ID of the model optimization iteration (there are \code{(n_iters + 1) * n_tries} iterations), the second column is the score of that iteration, then the following columns are about the hyperparameters used, while the last columns are the features used. It has \code{(n_iters + 1) * n_tries} rows, and \code{length(hyperparams[[i]][[1]]) + ncol(data) + 2} columns for a model of index \code{i} in \code{models}. Defaults to \code{NULL}, which means no logging.}

\item{maximize}{Type: boolean. Whether to maximize (\code{TRUE}) or minimize (\code{FALSE}) the metric returned by the model functions. Defaults to \code{TRUE}.}

\item{features}{Type: numeric. The approximate percentage of features that should be selected. This parameter is ignored when features when you underestimate the number of features you really need. Defaults to \code{0.50}, which means an attempt to use half of features only.}

\item{hyperparams}{Type: list of list of vector of numerics. Contains the hyperparameter interval to optimize per function. Each hyperparameter must have 4 lists, containing separately the mean (first list), the standard deviation (second list), the minimum (third list) and the maximum (fourth list) allowed. This is still used to fetch hyperparameters to pass when \code{optimize = FALSE}, you should just pass one vector per list in this specific case (containing the hyperparamters used for each model).}

\item{n_tries}{Type: numeric. The number of tries allowed to optimize per iteration of optimization of each model. To get the total number of models trained, you must multiplicate it with \code{n_iters + 1}. Defaults to \code{50}, which means \code{2550} models trained by default. Useless when \code{optimize = FALSE}.}

\item{n_iters}{Type: numeric. The numbers of iterations allowed for optimization of each model. To get the total number of models trained, you must multiplicate it with \code{n_tries} after adding \code{1} to \code{n_iters}. Defaults to \code{50}, which means \code{2550} models trained by default. Useless when \code{optimize = FALSE}.}

\item{early_stop}{Type: numeric. The number of optimization iterations allowed without any improvements of the metric returned by the model functions. Defaults to \code{5}, which means stopping after 6 optimization iterations without improvement of the metric returned by the model functions. Useless when \code{optimize = FALSE}.}

\item{elites}{Type: numeric. The percentage of best results taken in each iteration of optimization to use as a baseline. The higher the number, the slower the convergence (but the stabler the iteration updates). Must be between \code{0} and \code{1}. The multiplication of \code{n_tries} and \code{elites} must return an integer (and not decimal). Defaults to \code{0.1}.}

\item{feature_smoothing}{Type: numeric. The smoothing factor applied to feature selection to not pick strong features too fast. Must be between \code{0} and \code{1}. Defaults to \code{1}, which means no smoothing is applied. A lower value decreases the convergence speed.}

\item{converge_cont}{Type: numeric. The minimum allowed standard deviation of the maximum standard deviations of continuous variables. If all hyperparameters' standard deviation fall below \code{converge_cont} during optimization, we suppose the optimizer having converged. Defaults to \code{0.1}.}

\item{converge_disc}{Type: numeric. The minimum allowed single class probability of the maximum single class of discrete variables. If all features' maximum probability (of either 0 or 1) fall below \code{converge_disc} during optimization, we suppose the optimizer having converged. Defaults to \code{0.1}.}
}
\value{
The score of the models along with their hyperparameters.
}
\description{
This function attempts to perform automated modeling (use machine learning models, select features). It is optimized for maximum speed, therefore the user has a lot of chore to perform before using this function.
}
\details{
This is a mega function.
}
\examples{
\dontrun{
# Not tabulated well to keep under 100 characters per line
mega_model <- LauraeML(data = data,
label = targets,
folds = list(1:1460, 1461:2919),
seed = 0,
models = list(lgb = LauraeML_lgbreg,
              xgb = LauraeML_gblinear),
         parallelized = FALSE,
         optimize = TRUE,
         no_train = FALSE,
         logging = NULL,
         maximize = FALSE, # FALSE on RMSE, fast example of doing the worst
         features = 0.50,
         hyperparams = list(lgb = list(Mean = c(5, 5, 1, 0.7, 0.7, 0.5, 0.5),
                                       Sd = c(3, 3, 1, 0.2, 0.2, 0.5, 0.5),
                                       Min = c(1, 1, 0, 0.1, 0.1, 0, 0),
                                       Max = c(15, 50, 50, 1, 1, 50, 50)),
                            xgb = list(Mean = c(1, 1, 1),
                                       Sd = c(1, 1, 1),
                                       Min = c(0, 0, 0),
                                       Max = c(2, 2, 2))),
         n_tries = 10, # Set this big, preferably 10 * number of features
         n_iters = 1, # Set this big to like 50
         early_stop = 2,
         elites = 0.4,
         feature_smoothing = 1,
         converge_cont = 0.5,
         converge_disc = 0.25)
}

}

