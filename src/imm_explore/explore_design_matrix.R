##' ---
##' title: Building a predictive model for immunogenicity
##' --- 
##+ echo = FALSE
library(knitr)
library(rmarkdown)
opts_knit$set(root.dir = getwd())
opts_chunk$set(echo=TRUE, cache=F, warning = FALSE)
options(width=90)
##+
##' Get the data
library(data.table)
library(magrittr)
library(ggplot2)
library(tidyr)
library(rpart)
library(pROC)

dt <- fread("data/immunogenic_SNVs-model_data.csv")

dtm <- fread("data/all_methods.csv")
method_cols <- names(dt)[grepl(paste(dtm[, name], collapse = "|"), names(dt))]
other_cols <- names(dt)[!names(dt) %in% method_cols]

X <- dt[, method_cols, with = F]
y <- dt[, immune_response=="yes"]

##'
##' Many values are NA
dt %>% head(2)

##' ## Fraction of NA's for each method
##' 
X %>% sapply(. %>% is.na %>% mean) %>% .[order(names(.))] %>%
  barplot(ylab = "fraction missing", xlab = "method", main = "all y")

X %>% sapply(. %>% is.na %>% mean) %>% .[order(names(.))] 

##'
##' We can see that `pickpocket` and `netmhcpan` have the lowest values of NA's. I'll later fit the model only with these ones

##' 
##' ## Variables-response relation for all variables
##' 
##' 
##' Create delta and frac values: `mutant - wt`, `mutant / wt`
unique_method_cols <- tstrsplit(method_cols, "_")[[1]] %>% unique

for (method in unique_method_cols) {
  dt[, paste0(method, "_delta") := get(paste0(method, "_mutant")) - get(paste0(method, "_wt"))]
  dt[, paste0(method, "_frac") := get(paste0(method, "_mutant"))/get(paste0(method, "_wt"))]
}

all_method_cols <- c(method_cols, paste0(unique_method_cols, "_delta"))
## all_method_cols <- c(all_method_cols, paste0(unique_method_cols, "_frac"))
dt_melt <- melt(dt, measure.vars = all_method_cols, variable.name = "method")

##' 
##' Transform some values to the log scale:
#+ results = 'hide'
tolog <- c("arb", "bimas", "comblibsidney", "smm", "smmpmbec") 
dt_melt[method %in% tolog, value := log10(value )]
dt_melt <- separate(dt_melt, method, c("method", "type"))
## remove methods with all NA's
dt_melt <- dt_melt[, .SD[mean(is.na(value)) != 1], by = method]
##'
##' ### Boxplot
#+ fig.width = 6, fig.height = 10
qplot(immune_response, value, data = dt_melt, geom = "boxplot") +
  facet_grid(method~type, scales = "free") + geom_jitter(alpha = 0.1)

##'
##' Interesting observation: wt sequence needs to be more immunogenic per se.
##'
##' ### Prediction model
##'
##' Since many values are NA, we will use a decision tree.
cv_folds = function(n, folds = 10){
  split(sample(1:n), rep(1:folds, length = n))
}
set.seed(1)
folds <- cv_folds(nrow(X), folds = 10)
dt_full <- cbind(X, y)

dt_pred <- lapply(10^seq(-4, 5, by = 0.5), function(cp){
  lapply(folds, function(fold) {
    dt_train <- dt_full[-fold]
    dt_test <- dt_full[fold]
    rpart_fit <- rpart(y~., data = dt_train, control = rpart.control(cp = cp),
                       method = "class")
    return(data.table(cp = cp,
                      y = dt_test[, y],
                      y_pred = predict(rpart_fit, newdata = dt_test)[, 2]))
  }) %>% rbindlist
}) %>% rbindlist


##' Compute AUC for best cp:
res <- dt_pred[, .(auc = auc(y, y_pred)), by = cp][order(auc)][.N]
res

##' split rule:
cp_best <- res[, cp]
model <- rpart(y~., data = dt_train, control = rpart.control(cp = cp_best),
               method = "class")
#+ fig.height = 9
plot(model)
text(model)
#+ echo = FALSE
## #+ fig.width = 5, fig.height = 4
## qplot(netmhcpan_delta, pickpocket_delta, color = immune_response, shape = immune_response, data = dt)
##'
##'
##' ## Model with `r readLines('data/use_methods.txt')`
##' 
##' ### Dataset creation
##'
##' 
#+ echo = FALSE
## pairs(X[, !grepl("arb",names(X)) & grepl("_wt",names(X)), with = F],
##       col = y,
##       na.action = na.omit)
#+
use_methods <- readLines('data/use_methods.txt')
X_sub <- X[, grepl(paste(use_methods, collapse = "|"),names(X)), with = F]
keep <- complete.cases(X_sub)
y_sub <- y[keep]
X_sub <- X_sub[keep]

##' Fraction of data-points we are throwing away for selected methods:
#+ echo = TRUE
mean(keep)
##' ### Pairwise plot of features
##'
##'
##' Immunogenic changes are represented in red.
##' 
plot(X_sub, col = y_sub+1)

##'
##' We can see that it's very hard to separate the classes.
##' 
##' ## Prediction model
##'
##' 
##' Fit the glmnet model in 10-fold cross-validation using features: `r colnames(X_sub)`
library(glmnet)
set.seed(1)
fit <- cv.glmnet(as.matrix(X_sub), y_sub, alpha = 0,
                 nfolds = 10,
                 family ="binomial",
                 type.measure ="auc")
plot(fit)

coef(fit)


##'
##' Predictive performance is quite bad.

#+ echo = FALSE
## ##' 2d representation with TSNEG
## library(tsne)
## fit_tsne <- tsne(as.matrix(X_sub))
## plot(fit_tsne, col = y_sub+ 1)

