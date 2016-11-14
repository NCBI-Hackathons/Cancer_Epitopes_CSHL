##' ---
##' title: Explore the cancer immunity data (training_sets.xlsx)
##' author: Žiga Avsec
##' --- 

##+ set_workdir, echo=F
library(knitr)
library(rmarkdown)
opts_knit$set(root.dir = getwd())
opts_chunk$set(echo=TRUE, cache=F)
options(width=100)
#*

## read in the googledocs
library(data.table)
library(googlesheets)
library(magrittr)
library(stringdist)
library(readr)
suppressMessages(library(dplyr))

##'
##' ## Read in all the google sheets data
##' 
(my_sheets <- gs_ls())

##' - cancer_immunity.xlsx
cim <- gs_title("cancer_immunity.xlsx", verbose = FALSE)
## ctrain %>% gs_browse() ## open in browser
dt_cim <- cim %>% gs_read(ws = 1, verbose = FALSE) %>% as.data.table
dt_cim2 <- cim %>% gs_read(ws = 2, verbose = FALSE) %>% as.data.table

##' - training_sets.xlsx
#+ messages = FALSE
ctrain <- gs_title("training_sets.xlsx")
dt_ctrain_m_vs_wt <- ctrain %>% gs_read(ws = 1, verbose = FALSE) %>% as.data.table
dt_ctrain_binder_vs_nbinder <- ctrain %>% gs_read(ws = 2, verbose = FALSE) %>% as.data.table

##'
##' ## Sanity checks
##'
##' ### training_sets.xlsx

##' Both have to have the same length
dt_ctrain_m_vs_wt[, nchar(mutant_sequence) != nchar(wt_sequence)] %>% sum
dt_ctrain_m_vs_wt <- dt_ctrain_m_vs_wt[nchar(mutant_sequence) == nchar(wt_sequence)]

##' It should be a single-nucleotide substitution SNV (they should differ only at one base)
dt_ctrain_m_vs_wt[,stringdist(mutant_sequence, wt_sequence)] %>% table(useNA = "always")
dt_ctrain_m_vs_wt <- dt_ctrain_m_vs_wt[stringdist(mutant_sequence, wt_sequence) == 1 ]

##' Only non NA sequences with unique rows
dt_ctrain_m_vs_wt <- dt_ctrain_m_vs_wt[!is.na(wt_sequence) & !is.na(mutant_sequence)] %>% unique

##'
##' ## Exploratory analysis

##' - Peptide lengths
dt_ctrain_m_vs_wt[, mutant_sequence] %>% nchar %>% table(useNA = "always")

##' - Number of unique sequences:
dt_ctrain_m_vs_wt %>% uniqueN
##'
##' - Duplicated sequneces
dt_ctrain_m_vs_wt[wt_sequence %in% wt_sequence[duplicated(wt_sequence)]]

##'
##' - All are binders, immune_response
dt_ctrain_m_vs_wt[, .(binder, type)] %>% table(useNA = "always")

##' - Number of peptides with the concentration value
dt_ctrain_m_vs_wt[, is.na(concentration_nM)] %>% table(useNA = "always")

##' - Number of different publications/data-sources
dt_ctrain_m_vs_wt[, .N, by = reference][order(-N)]

##' - Identified by
dt_ctrain_m_vs_wt[, .N, by = identified_by][order(-N)]

##' - Binding to 
dt_ctrain_m_vs_wt[, .N, by = binding_to][order(-N)]

##'
##' ## Save the model to csv

write_csv(dt_ctrain_m_vs_wt, "data/immunogenic_SNVs-training_sets.csv")
