# install.packages("remotes")
# remotes::install_github("muschellij2/fedreporter")
library(fedreporter)


setwd("~/github/scholar/")
load("./Desktop/Advanced data Science/scholar/citation.RData")

courseInfo <- read.csv("jhsph_courseinfo.csv")

# create lists of names from original citation and courseInfo files
first_name_list <- courseInfo$Firstname
last_name_list <- as.character(courseInfo$Lastname)
more_names <- names(citation)
more_names_list <- strsplit(more_names, " ")
# more_firsts <- lapply(X = more_names_list,FUN = "[[", 1)
# more_lasts <- lapply(X = more_names_list,FUN = "[[", 2)

more_firsts <- map_chr(more_names_list, `[[`, 1)
more_lasts <- map_chr(more_names_list, `[[`, 2)

first_name_list <- gsub("\\s+.+", "", first_name_list)

all_firsts <- c(first_name_list, more_firsts)
all_lasts <- c(last_name_list, more_lasts)

# create combined list of names
name_list <- paste0(all_lasts, ", ", all_firsts)

head(pi_list)

# scraping original grants data
dat <- map(
  .x = pi_list,
  .f = ~ try(fe_projects_search(pi_name = .x)$content$items)
)

# rename scraped data
grant_nested_list <- dat

# create dataframe from nested list
grant_flat <- grant_nested_list %>% flatten()
grant_keep <- grant_flat %>% modify_depth(1, length) == 27
grant_flat <- grant_flat[grant_keep]
grant_null <- grant_flat %>% modify_depth(2, is.null)
nullToNA <- function(x) {
  x[sapply(x, is.null)] <- NA
  return(x)
}
library(data.table)
grant_df <- map(grant_flat, nullToNA) %>% rbindlist()

# write out the scraped data as rds file
library(readr)
readr::write_rds(x = name_list, path = "name_list.rds", compress = "none")
readr::write_rds(x = all_firsts, path = "first_name_list.rds", compress = "none")
readr::write_rds(x = all_lasts, path = "last_name_list.rds", compress = "none")
readr::write_rds(x = grant_nested_list, path = "grant_nested_list.rds", compress = "none")
readr::write_rds(x = grant_df, path = "grant_df.rds", compress = "none")


# trim grant df based on names.csv
setwd("~/github/scholar/")

library(readr)
grant_df <- read_rds("grant_df.rds")
final_name_list <- read_csv("names.csv")
library(stringr)
final_name_list <- str_split(string = final_name_list$Name, pattern = " ")

library(purrr)
firsts <- map_chr(final_name_list, `[[`, 1)
lasts <- map_chr(final_name_list, `[[`, 2)

# which2keep <- function(x, lastname,firstname){
#     grepl(pattern = paste0("^",lastname,", ",firstname),
#                              x = x,
#                              ignore.case = TRUE)
# }
# test which2keep function
# any(which2keep(grant_df$contactPi, lasts[1], firsts[1]))

lastname_match <- map_chr(str_split(grant_df$contactPi, ", "), `[[`, 1) %in% toupper(lasts)

firstname_match <- map_chr(str_split(grant_df$contactPi, " "), `[[`, 2) %in% toupper(firsts)

bothname_match <- lastname_match == TRUE & firstname_match == TRUE

scholar_df <- grant_df[bothname_match, ]

scholar_df$contactPi <- gsub(pattern = "\\.", replacement = "", x = scholar_df$contactPi)

length(unique(scholar_df$contactPi))
unique(scholar_df$contactPi)
lastname_missing <- !(toupper(lasts) %in%
  unique(map_chr(str_split(scholar_df$contactPi, ", "), `[[`, 1))
)
missing_lastnames <- lasts[lastname_missing]
missing_lastnames

readr::write_rds(x = scholar_df, path = "scholar_df.rds", compress = "none")
