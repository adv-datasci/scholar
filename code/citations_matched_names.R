#install.packages("remotes")
#remotes::install_github("muschellij2/fedreporter")
library(fedreporter)
library(stringr)
library(readr)

# load("citation.RData")
load(here("data/gcite.RData"))
course = read.csv(here("data/jhsph_courseinfo.csv"))
grant_df<-read_rds(here("data/grant_df.rds"))
name_list <- read_csv(here("data/names.csv"))
name_list  <- str_split(string = name_list$Name, pattern = " ")

library(purrr)
cite_firsts <- map_chr(name_list, `[[`, 1)
cite_lasts <- map_chr(name_list, `[[`, 2)

#create combined list of names
pi_list <- paste0(lasts, ", ", firsts)

# Remove periods
course$Firstname <- gsub(pattern = "\\.", replacement = "", x = course$Firstname)

# Separate middle initials
course_firstname <- str_split(string = course$Firstname, pattern = " ")
# Keep only first names (not middle initials)
course_firsts <- map_chr(course_firstname, `[[`, 1)
# obtain last names from course df
course_lasts <- course$Lastname
# obtain last names from grant df
grant_lasts <- str_to_title(map_chr(str_split(grant_df$contactPi, ", "),`[[`, 1))
# add last names to grant df as new column
grant_df[,"Lastname"] <- grant_lasts

grant_firsts <- str_to_title(map_chr(str_split(grant_df$contactPi, " "),`[[`, 2))

# flatten nested list
cite_flat <- l %>% flatten()

# now newst

test <- l[["Alison Abraham"]]

test <- l[[paste(course_firsts[2],course_lasts[2], sep = " ")]]

library(data.table)
cite_df <- cite_flat %>% rbindlist()


lastname_match <- map_chr(str_split(grant_df$contactPi, ", "),`[[`, 1) %in% toupper(course_df$Lastname)

firstname_match <-  map_chr(str_split(grant_df$contactPi, " "),`[[`, 2) %in% toupper(map_chr(str_split(course_df$Firstname, " "),`[[`, 1))

bothname_match <- lastname_match == TRUE & firstname_match == TRUE

grant_df <- grant_df[bothname_match,]

length(unique(grant_df$contactPi))

readr::write_rds(x = scholar_df, path = "grant_df.rds", compress = "none")
