# install.packages("remotes")
# remotes::install_github("muschellij2/fedreporter")
library(fedreporter)


setwd("~/github/scholar/")

library(readr)
courses <- read_csv("jhsph_courseinfo.csv")
grant_df <- read_rds("grant_df.rds")

library(stringr)
name_list <- str_split(string = grant_df$contactPi, pattern = ", ")

library(purrr)
firsts <- map_chr(name_list, `[[`, 2)
lasts <- map_chr(name_list, `[[`, 1)

lastname_match <- toupper(courses$Lastname) %in% toupper(lasts)

courses$Firstname <- gsub(pattern = "\\.", replacement = "", x = courses$Firstname)

firstname_match <- toupper(map_chr(str_split(courses$Firstname, " "), `[[`, 1)) %in% toupper(map_chr(str_split(firsts, " "), `[[`, 1))

bothname_match <- lastname_match == TRUE & firstname_match == TRUE
any(bothname_match)
course_df <- courses[bothname_match, ]

readr::write_rds(x = course_df, path = "course_df.rds", compress = "none")
