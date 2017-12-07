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
grants <- dat
library(readr)
readr::write_rds(x = name_list,path = "name_list.rds", compress = "none")
readr::write_rds(x = all_firsts, path = "first_name_list.rds", compress = "none")
readr::write_rds(x = all_lasts, path = "last_name_list.rds", compress = "none")
readr::write_rds(x = grants, path = "grant_nested_list.rds", compress = "none")

# get_scholar_df = function(firstname, lastname){
# res = fe_projects_search(pi_name = paste0(lastname,", ",firstname))
#> GET command is:
#> Response [https://api.federalreporter.nih.gov/v1/Projects/search?query=piName%3AMATSUI%2C%20ELIZABETH&offset=1&limit=50]
#>   Date: 2017-10-03 15:33
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 128 kB
# items = res$content$items
# con_pis = sapply(items, "[[", "contactPi")
# keep = grepl(paste0("^",lastname), con_pis)
# items = items[keep]
# }
# get_list = function(x) {sapply(items, "[[", x)}
# item_names=names(items[[1]])
# length(items)
# df = data.frame(lapply(item_names,get_list))
# names(df)=item_names[1:12]
# write.csv(x = df,file = paste0(lastname,"_",firstname,".csv"))
# head(df)
# class(items)
# nullToNA <- function(x) {
#   x[sapply(x, is.null)] <- NA
#   return(x)
# }
# for(i in 1:length(items)){
#   items_df 
#   lapply(items[[i]], nullToNA)
# }
# items <- lapply(items[2], nullToNA)
# scholar_search(firstname = first_name,lastname = last_name)
# class(citation)
