##' ---
##' title: Building a predictive model for immunogenicity
##' --- 
##+ echo = FALSE
library(knitr)
library(rmarkdown)
opts_knit$set(root.dir = getwd())
opts_chunk$set(echo=TRUE, cache=F)
options(width=90)
##+
##' Get the data
library(data.table)
library(magrittr)
library(ggplot2)

dt <- fread("data/binders_design_matrix.csv")

dtm <- fread("data/methods.csv")

method_cols <- names(dt)[names(dt) %in% dtm[, name]]
other_cols <- names(dt)[!names(dt) %in% dtm[, name]]

X <- dt[, method_cols, with = F]
y <- dt[, binder=="yes"]

##'
##' Many values for binder == "yes" are NA
dt[binder == "yes"] %>% head
##' ## Fraction of NA's for each method
##' y == TRUE
sum(y==TRUE)
X[y == TRUE] %>% sapply(. %>% is.na %>% mean)


##' y == FALSE
sum(y==FALSE)
X[y == FALSE] %>% sapply(. %>% is.na %>% mean)

dt_melt <- melt(dt, measure.vars = method_cols, variable.name = "method")

##' 
##' ## Variables-response relation
##' 
##' Transform some values to the log scale:
#+ results = 'hide'
tolog <- c("arb", "bimas", "comblibsidney", "smm", "smmpmbec") 
dt_melt[method %in% tolog, value := log10(value )]

#+ fig.width = 8, fig.height = 5
qplot(binder, value, data = dt_melt, geom = "boxplot") + facet_wrap(~method, scales = "free") + geom_jitter(alpha = 0.1)

#+ fig.width = 5, fig.height = 4
qplot(netmhcpan, pickpocket, color = binder, shape = binder, data = dt)
