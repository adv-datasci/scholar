# install.packages("remotes")
# remotes::install_github("muschellij2/fedreporter")
library(fedreporter)
library(readr)
library(stringr)

name_list <- read_csv(here("data/names.csv"))
name_list <- str_split(string = name_list$Name, pattern = " ")

firsts <- map_chr(name_list, `[[`, 1)
lasts <- map_chr(name_list, `[[`, 2)

# create combined list of names
pi_list <- paste0(lasts, ", ", firsts)

# scraping grants data
grant_nested_list <- map(
  .x = pi_list,
  .f = ~ try(fe_projects_search(pi_name = .x)$content$items)
)

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
readr::write_rds(x = grant_df, path = "grant_df.rds", compress = "none")
object.size(grant_df)


library(readr)
grant_df <- read_rds(here("data/grant_df.rds"))
name_list <- read_csv(here("data/names.csv"))
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

lastname_match <- map_chr(str_split(grant_df$contactPi, ", "), `[[`, 1) %in% toupper(course_df$Lastname)

firstname_match <- map_chr(str_split(grant_df$contactPi, " "), `[[`, 2) %in% toupper(map_chr(str_split(course_df$Firstname, " "), `[[`, 1))

bothname_match <- lastname_match == TRUE & firstname_match == TRUE

grant_df <- grant_df[bothname_match, ]

length(unique(grant_df$contactPi))

readr::write_rds(x = grant_df, path = "grant_df.rds", compress = "none")
