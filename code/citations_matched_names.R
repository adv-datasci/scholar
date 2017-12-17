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

course_fulls <- paste0(course_lasts, ", ", course_firsts)
grant_fulls <- paste0(grant_lasts, ", ", grant_firsts)
cite_fulls <- paste0(cite_lasts, ", ", cite_firsts)

# keep only name matches
grant_fullname_match <- grant_fulls %in% cite_fulls
course_fullname_match <- course_fulls %in% cite_fulls

# grant_lastname_match <- grant_lasts %in% cite_lasts
# 
# grant_firstname_match <-  grant_firsts %in% cite_firsts
# 
# grant_bothname_match <- grant_lastname_match == TRUE & grant_firstname_match == TRUE
# 
# 
# course_lastname_match <- course_lasts %in% cite_lasts
# 
# course_firstname_match <-  course_firsts %in% cite_firsts
# 
# course_bothname_match <- course_lastname_match == TRUE & course_firstname_match == TRUE
# 
# course_df_match <- course[course_bothname_match,]

grant_df_match <- grant_df[grant_fullname_match,]

course_df_match <- course[course_fullname_match,]

readr::write_rds(x = grant_df_match, path = "grant_df_matched.rds", compress = "none")

readr::write_rds(x = course_df_match, path = "course_df_matched.rds", compress = "none")

cite_names <- data_frame(Lastname=cite_lasts,
                         Firstname=cite_firsts,
                         Fullname=paste0(cite_lasts, ", ", cite_firsts))

cite_name_match1 <- cite_names$Fullname %in% grant_df_match$Fullname 
cite_name_match2 <- cite_names$Fullname %in% course_df_match$Fullname

cite_bothname_match <- cite_name_match1 == TRUE & cite_name_match2 == TRUE

cite_names_match <- cite_names[cite_bothname_match,]

cite_first_last <- paste(cite_names_match$Firstname, cite_names_match$Lastname, sep = " ")

cite_df_keep <- names(l) %in% cite_first_last

cite_df_list <- l[cite_df_keep]

readr::write_rds(x = cite_df_list, path = "cite_df_list_matched.rds", compress = "none")
