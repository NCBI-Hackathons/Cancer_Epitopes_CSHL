file_in <- "/home/avsec/Cancer_Epitopes_CSHL/data/binders.csv"


dt <- fread(file_in)

dt[, allele] %>% table

dt[, nchar(Sequence)] %>% table

dt$allele <- gsub("\\*","",dt$allele)
dt$allele <- gsub("(-[a-zA-Z]+)([0-9]{4})","\\1\\*:\\2",dt$allele)
readr::write_csv(dt, file_in)
