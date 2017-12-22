library(dplyr)
rawtxt <- readLines("https://www.jhsph.edu/faculty/directory/facultyList.cfc?method=getFacultyList")
splittxt <- gsub("[\\{\\}]", "", regmatches(rawtxt, gregexpr("\\{.*?\\}", rawtxt))[[1]])
jhsph_faculty <- as.data.frame(splittxt %>% strsplit("\\\"") %>% sapply(., "[", c(4, 10, 14, 26)) %>% t())
names(jhsph_faculty) <- c("Department", "Site", "Name", "Position")
## remove non-faculty
jhsph_faculty <- jhsph_faculty %>% filter(grepl("Professor|Scientist", Position))
jhsph_faculty <- jhsph_faculty %>% mutate(Tenure_track = ifelse(grepl("Professor", Position), "Yes", "No"))

## Get URL for each faculty member
jhsph_faculty <- jhsph_faculty %>% mutate(URL = paste0("https://www.jhsph.edu/faculty/directory/profile/", Site))

library(readr)

readr::write_rds(x = jhsph_faculty, path = "jhsph_faculty.rds", compress = "none")

## check faculty counts by department
table(jhsph_faculty$Department, jhsph_faculty$Tenure_track)
