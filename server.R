library(shiny)
library(ggplot2)
library(fedreporter)
library(stringr)
# Elizabeth Colantuoni
setwd("~/github/scholar/")
load("citation.RData")
grant_nested_list<-read_rds("grant_nested_list.rds")
course = read.csv("jhsph_courseinfo.csv")
name_list<-read_rds("name_list.rds")
first_name_list <- read_rds("first_name_list.rds")
last_name_list <- read_rds("last_name_list.rds")
# con_pis = sapply(grant_nested_list, "[[", "contactPi")
# keep = grepl(as.character(paste0("^",l)), con_pis)[1]
# affiliation = [keep]
function(input, output) {
  output$name = renderText({
    input$goButton
    fullname = isolate(input$fullname)
    # splitname = str_split(string = fullname, 
    #                       pattern = ", ")[[1]]
    # f = splitname[1]
    # l = splitname[2]
    # out = paste0("Name: ", f,", ", l)
    out = paste0("Name: ", fullname)
    print(out)
  })
  
  output$index = renderText({
    input$goButton
    fullname = isolate(input$fullname)
    index = which(name_list==fullname)[1]
    out = paste0("Index: ", index)
    print(out)
  })
    
  output$department = renderText({
    input$goButton
    fullname = isolate(input$fullname)
    index = which(name_list==fullname)[1]
    match_row <- which(course$Lastname == last_name_list[index])
    out = paste0("Department: ", as.character(course[match_row, 1]))
    print(out)
  })
  
  output$title = renderText({
    input$goButton
    fullname = isolate(input$fullname)
    index = which(name_list==fullname)[1]
    match_row <- which(course$Lastname == last_name_list[index])
    out = paste0("Position: ", as.character(course[match_row, 2]))
    print(out)
  })
  
  output$class = renderUI({
    input$goButton
    fullname = isolate(input$fullname)
    index = which(name_list==fullname)[1]
    match_row <- which(course$Lastname == last_name_list[index])
    allc = as.character(course[match_row, 6])
    allc = str_split(allc, pattern = fixed(", "), simplify = T)
    out = ""
    for (i in 1:length(allc)){
      out = paste(out, allc[i], sep = '<br/>')
    }
    HTML(out)
  })
  
  output$publication = renderTable({
    input$goButton
    fullname = isolate(input$fullname)
    splitname = str_split(string = fullname, 
                          pattern = ", ")[[1]]
    f = splitname[1]
    l = splitname[2]
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,c(1,3)]
    print(t)
  })
  
  output$citeplot = renderPlot({
    input$goButton
    fullname = isolate(input$fullname)
    splitname = str_split(string = fullname, 
                          pattern = ", ")[[1]]
    f = splitname[1]
    l = splitname[2]
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,9:18]
    citey = colSums(t)
    cy = data.frame(names(citey), citey)
    colnames(cy) = c("x", "y")
    p = ggplot(data = cy, aes(x, y, group = 1)) + geom_point() + geom_line()
    p + labs(x = "Year", y = "Total Citation", title = "Total Publication Citation")
  })
  
  output$pubbar = renderPlot({
    input$goButton
    fullname = isolate(input$fullname)
    splitname = str_split(string = fullname, 
                          pattern = ", ")[[1]]
    f = splitname[1]
    l = splitname[2]
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,3]
    t = t[!is.na(t)]
    yr = data.frame(str_split(t, pattern = fixed("/"), simplify = T)[,1])
    colnames(yr) = "Year"
    g = ggplot(yr, aes(Year))
    g + geom_bar() + labs(x = "Year", y = "Total Publication", title = "Total Publication Every Year")
  })
  
  output$publication = renderTable({
    input$goButton
    fullname = isolate(input$fullname)
    splitname = str_split(string = fullname, 
                          pattern = ", ")[[1]]
    f = splitname[1]
    l = splitname[2]
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,c(1,3)]
    print(t)
  })

  output$grant = renderTable({
    # install.packages("remotes")
    # remotes::install_github("muschellij2/fedreporter")
    input$goButton
    last_name = isolate(input$last)
    first_name = isolate(input$first)
    scholar_search = function(firstname, lastname){
      res = fe_projects_search(pi_name = paste0(lastname,", ",firstname))
      items = res$content$items
      con_pis = sapply(items, "[[", "contactPi")
      keep = grepl(paste0("^",lastname), con_pis)
      items = items[keep]
      get_list = function(x) {sapply(items, "[[", x)}
      item_names=names(items[[1]])
      df = data.frame(lapply(item_names[1:12],get_list))
      names(df)=item_names[1:12]
      return(df$fy)
    }
    a = scholar_search(firstname = first_name,lastname = last_name)
    print.data.frame(a)
  })
}
  

  

# name
# affiliation + citationplot + yearpublication (title click get paper)
# + year + barplot 
