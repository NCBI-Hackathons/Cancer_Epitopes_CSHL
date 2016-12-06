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

dt <- fread("data/immunogenic_SNVs-model_data.csv")

dtm <- fread("data/all_methods.csv")

method_cols <- names(dt)[grepl(paste(dtm[, name], collapse = "|"), names(dt))]
other_cols <- names(dt)[!names(dt) %in% method_cols]

X <- dt[, method_cols, with = F]
y <- dt[, immune_response=="yes"]

##'
##' Many values for binder == "yes" are NA
dt[immune_response == "yes"] %>% head
##' ## Fraction of NA's for each method
##' y == TRUE
sum(y==TRUE)
mean(y==TRUE)


X %>% sapply(. %>% is.na %>% mean) %>% .[order(names(.))] %>%
  barplot(ylab = "fraction missing", xlab = "method", main = "all y")

##' y == FALSE
sum(y==FALSE)
X[y == FALSE] %>% sapply(. %>% is.na %>% mean)

## TODO create delta values
unique_method_cols <- tstrsplit(method_cols, "_")[[1]] %>% unique

for (method in unique_method_cols) {
  dt[, paste0(method, "_delta") := get(paste0(method, "_mutant")) - get(paste0(method, "_wt"))]
  dt[, paste0(method, "_frac") := get(paste0(method, "_mutant"))/get(paste0(method, "_wt"))]
}

all_method_cols <- c(method_cols, paste0(unique_method_cols, "_delta"))
## all_method_cols <- c(all_method_cols, paste0(unique_method_cols, "_frac"))
dt_melt <- melt(dt, measure.vars = all_method_cols, variable.name = "method")

##' 
##' ## Variables-response relation
##' 
##' Transform some values to the log scale:
#+ results = 'hide'
tolog <- c("arb", "bimas", "comblibsidney", "smm", "smmpmbec") 
dt_melt[method %in% tolog, value := log10(value )]
dt_melt <- separate(dt_melt, method, c("method", "type"))
## remove methods with all NA's
dt_melt <- dt_melt[, .SD[mean(is.na(value)) != 1], by = method]
#+ fig.width = 6, fig.height = 10
qplot(immune_response, value, data = dt_melt, geom = "boxplot") +
  facet_grid(method~type, scales = "free") + geom_jitter(alpha = 0.1)

#+ fig.width = 5, fig.height = 4
qplot(netmhcpan_delta, pickpocket_delta, color = immune_response, shape = immune_response, data = dt)


############################################
## is there anything useful we can learn?
