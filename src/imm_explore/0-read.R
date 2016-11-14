## read in the googledocs
library(data.table)
library(googlesheets)
library(magrittr)
suppressMessages(library(dplyr))

##'
##' ## Read in all the google sheets data
##' 
(my_sheets <- gs_ls())

##' - cancer_immunity.xlsxx
cim <- gs_title("cancer_immunity.xlsx")
## ctrain %>% gs_browse() ## open in browser
dt_cim <- cim %>% gs_read(ws = 1) %>% as.data.table
dt_cim2 <- cim %>% gs_read(ws = 2) %>% as.data.table

##' - training_sets.xlsx
ctrain <- gs_title("training_sets.xlsx")
dt_ctrain_m_vs_wt <- ctrain %>% gs_read(ws = 1) %>% as.data.table
dt_ctrain_binder_vs_nbinder <- ctrain %>% gs_read(ws = 2) %>% as.data.table

##'
##' ## Sanity checks
##'
##' ### training_sets.xlsx

##' Both have to have the same length
dt_ctrain_m_vs_wt[, nchar(mutant_sequence) != nchar(wt_sequence)] %>% sum
dt_ctrain_m_vs_wt <- dt_ctrain_m_vs_wt[nchar(mutant_sequence) == nchar(wt_sequence)]

##' It should be a single-nucleotide substitution SNV (they should differ only at one base)
library(stringdist)
dt_ctrain_m_vs_wt[,stringdist(mutant_sequence, wt_sequence)] %>% table
dt_ctrain_m_vs_wt <- dt_ctrain_m_vs_wt[stringdist(mutant_sequence, wt_sequence) == 1 ]

##' Peptide lengths
dt_ctrain_m_vs_wt[, mutant_sequence] %>% nchar %>% table

