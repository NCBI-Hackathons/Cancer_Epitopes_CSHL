ctrain <- gs_title("training_sets.xlsx")
dt_initial <- ctrain %>% gs_read(ws = 1, verbose = FALSE) %>% as.data.table
dt_final <- fread("~/Cancer_Epitopes_CSHL/data/immunogenic_SNVs-model_data.csv")

cols <- c("mutant_sequence", "concentration_nM", "wt_sequence", "reference")

setkeyv(dt_final, cols)
setkeyv(dt_initial, cols)

merge(dt_initial, dt_final[, cols, with = F], on = cols)
dt_initial[!dt_final[, cols, with = F], on = cols]
dt_final[!dt_initial, on = cols]
