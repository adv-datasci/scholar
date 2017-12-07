names(courseInfo)
first_name_list <- courseInfo$Firstname
last_name_list <- courseInfo$Lastname
head(first_name_list)
head(last_name_list)
first_name_list <- gsub("\\s+.+","",first_name_list)
scholar_search(firstname = first_name_list,lastname = last_name_list)
mapply(FUN = scholar_search,firstname = first_name_list, lastname = last_name_list)
