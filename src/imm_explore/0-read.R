dt_ctrain_m_vs_wt <- fread("Cancer_Epitopes_CSHL/data/training.csv")

##' Consider only non NA sequences with unique rows
dt_ctrain_m_vs_wt <- dt_ctrain_m_vs_wt[!is.na(wt_sequence) & !is.na(mutant_sequence)] %>% unique

##' Both have to have the same length
dt_ctrain_m_vs_wt[nchar(mutant_sequence) == nchar(wt_sequence)]

##' ## Exploratory analysis

##' - Peptide lengths
dt_ctrain_m_vs_wt[, nchar(mutant_sequence)] %>% table(useNA = "always")

##' - Number of unique sequences:
dt_ctrain_m_vs_wt %>% uniqueN
##'
##' - Duplicated sequneces
dt_ctrain_m_vs_wt[wt_sequence %in% wt_sequence[duplicated(wt_sequence)]]

##'
##' - mutant eliciting immune_response
dt_ctrain_m_vs_wt[, .N, immune_response] 

##'
##' ## Save the model to csv

write_csv(dt_ctrain_m_vs_wt, "Cancer_Epitopes_CSHL/data/immunogenic_SNVs-training_sets.csv")
