install.packages("remotes")
remotes::install_github("muschellij2/fedreporter")
library(fedreporter)

last_name = "MATSUI"
first_name = "ELIZABETH"
scholar_search = function(firstname, lastname){
res = fe_projects_search(pi_name = paste0(lastname,", ",firstname))
#> GET command is:
#> Response [https://api.federalreporter.nih.gov/v1/Projects/search?query=piName%3AMATSUI%2C%20ELIZABETH&offset=1&limit=50]
#>   Date: 2017-10-03 15:33
#>   Status: 200
#>   Content-Type: application/json; charset=utf-8
#>   Size: 128 kB
items = res$content$items
con_pis = sapply(items, "[[", "contactPi")
keep = grepl(paste0("^",lastname), con_pis)
items = items[keep]
get_list = function(x) {sapply(items, "[[", x)}
item_names=names(items[[1]])
df = data.frame(lapply(item_names[1:12],get_list))
names(df)=item_names[1:12]
write.csv(x = df,file = paste0(lastname,"_",firstname,".csv"))
head(df)
}
scholar_search(firstname = first_name,lastname = last_name)
setwd("./github/scholar/")
getwd()
