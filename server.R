library(shiny)
library(ggplot2)
library(fedreporter)
# Elizabeth Colantuoni
load("citation.RData")
course = read.csv("jhsph_courseinfo.csv")

function(input, output) {
  output$name = renderText({
    input$goButton
    f = isolate(input$first)
    l = isolate(input$last)
    out = paste("Name:", f, l)
    out
  })
  
  output$department = renderText({
    input$goButton
    f = isolate(input$first)
    l = isolate(input$last)
    out = paste("Affiliation: ", as.character(course[which(course$Firstname == f & course$Lastname == l), 1]))
    out
  })
  
  output$class = renderUI({
    input$goButton
    f = isolate(input$first)
    l = isolate(input$last)
    allc = as.character(course[which(course$Firstname == f & course$Lastname == l), 6])
    library(stringr)
    allc = str_split(allc, pattern = fixed(", "), simplify = T)
    out = ""
    for (i in 1:length(allc)){
      out = paste(out, allc[i], sep = '<br/>')
    }
    HTML(out)
  })
  
  output$publication = renderTable({
    input$goButton
    f = isolate(input$first)
    l = isolate(input$last)
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,c(1,3)]
    t
  })
  
  output$citeplot = renderPlot({
    input$goButton
    f = isolate(input$first)
    l = isolate(input$last)
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
    f = isolate(input$first)
    l = isolate(input$last)
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
    f = isolate(input$first)
    l = isolate(input$last)
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,c(1,3)]
    t
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
