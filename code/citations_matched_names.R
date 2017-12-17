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
# obtain first names from grant df
grant_firsts <- str_to_title(map_chr(str_split(grant_df$contactPi, " "),`[[`, 2))

# replace last names to course df as new column
course[,"Lastname"] <- course_lasts
# replace first names to course df as new column
course[,"Firstname"] <- course_firsts
# add full names to course df as new column
course[,"Fullname"] <- paste0(course_lasts, ", ", course_firsts)

# add last names to grant df as new column
grant_df[,"Lastname"] <- grant_lasts
# add first names to grant df as new column
grant_df[,"Firstname"] <- grant_firsts
# add full names to grant df as new column
grant_df[,"Fullname"] <- paste0(grant_lasts, ", ", grant_firsts)



lastname_match <- map_chr(str_split(grant_df$contactPi, ", "),`[[`, 1) %in% toupper(course_df$Lastname)

firstname_match <-  map_chr(str_split(grant_df$contactPi, " "),`[[`, 2) %in% toupper(map_chr(str_split(course_df$Firstname, " "),`[[`, 1))

bothname_match <- lastname_match == TRUE & firstname_match == TRUE

grant_df <- grant_df[bothname_match,]

length(unique(grant_df$contactPi))

readr::write_rds(x = scholar_df, path = "grant_df.rds", compress = "none")
