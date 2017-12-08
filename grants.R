#install.packages("remotes")
#remotes::install_github("muschellij2/fedreporter")
library(fedreporter)
library(purrr)

setwd("~/github/scholar/")
load("./Desktop/Advanced data Science/scholar/citation.RData")

courseInfo<-read.csv("jhsph_courseinfo.csv")

first_name_list <- courseInfo$Firstname
last_name_list <- as.character(courseInfo$Lastname)
more_names <- names(citation)
more_names_list <- strsplit(more_names," ")
#more_firsts <- lapply(X = more_names_list,FUN = "[[", 1)
#more_lasts <- lapply(X = more_names_list,FUN = "[[", 2)

more_firsts <- map_chr(more_names_list, `[[`, 1)
more_lasts <- map_chr(more_names_list, `[[`, 2)

first_name_list <- gsub("\\s+.+","",first_name_list)

all_firsts <- c(first_name_list,more_firsts)
all_lasts <- c(last_name_list,more_lasts)


name_list <- paste0(all_lasts, ", ", all_firsts)

head(pi_list)

dat <- map(
  .x = pi_list,
  .f = ~ try(fe_projects_search(pi_name = .x)$content$items))

#saveRDS(object = pi_list, file = "pi_list.rds", compress = FALSE)
grant_nested_list <- dat

grant_flat <- grant_nested_list %>% flatten()
grant_keep <- grant_flat %>% modify_depth(1,length)==27
grant_flat <- grant_flat[grant_keep]
grant_null <- grant_flat %>% modify_depth(2, is.null) 
nullToNA <- function(x) {
    x[sapply(x, is.null)] <- NA
    return(x)
}
library(data.table)
grant_df <- map(grant_flat, nullToNA) %>% rbindlist()

library(readr)
readr::write_rds(x = name_list,path = "name_list.rds", compress = "none")
readr::write_rds(x = all_firsts, path = "first_name_list.rds", compress = "none")
readr::write_rds(x = all_lasts, path = "last_name_list.rds", compress = "none")
readr::write_rds(x = grant_nested_list, path = "grant_nested_list.rds", compress = "none")
readr::write_rds(x = grant_df, path = "grant_df.rds", compress = "none")
