library(shiny)
library(magrittr)
library(purrr)
library(plotly)
#install.packages("plotly")
library(lubridate)
library(ggplot2)
library(fedreporter)
library(stringr)
library(readr)
# Elizabeth Colantuoni
setwd("~/github/scholar/")
load("citation.RData")
grant_df <- read_rds("grant_df.rds")
course_df <- read_rds("course_df.rds")
name_list<-grant_df$contactPi
first_name_list <- read_rds("first_name_list.rds")
last_name_list <- read_rds("last_name_list.rds")

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
    l = splitname[1]
    f = splitname[2]
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,c(1,3)]
    print(t)
  })
  
  output$citeplot = renderPlot({
    input$goButton
    fullname = isolate(input$fullname)
    splitname = str_split(string = fullname, 
                          pattern = ", ")[[1]]
    l = splitname[1]
    f = splitname[2]
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
    l = splitname[1]
    f = splitname[2]
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
    l = splitname[1]
    f = splitname[2]
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,c(1,3)]
    print(t)
  })

  output$grant_tbl = renderTable({
    input$goButton
    fullname = isolate(input$fullname)
    # splitname = str_split(string = fullname, 
    #                       pattern = ", ")[[1]]
    # l = splitname[1]
    # f = splitname[2]
    # contactPi_name_keep <- grepl(pattern = paste0("^",l,", ",f),
    #                              x = grant_df$contactPi,
    #                              ignore.case = TRUE)
    contactPi_keep <- grepl(pattern = paste0("^",fullname),
                                 x = grant_df$contactPi,
                                 ignore.case = TRUE)
    contactPi_df <- grant_df[contactPi_keep,] %>% 
        dplyr::select(projectNumber,
                      fy,
                      title,
                      totalCostAmount) 
    
    print.data.frame(contactPi_df)
  })
  
  # FIRST REACTIVE PLOT
    ## Reactive plot: Grant funding pie chart
  output$grant_pie <- renderPlotly({
    input$goButton
    fullname = isolate(input$fullname)
    contactPi_keep <- grepl(pattern = paste0("^",fullname),
                            x = grant_df$contactPi,
                            ignore.case = TRUE)
    contactPi_df <- grant_df[contactPi_keep,]
    contactPi_sum <- contactPi_df %>% dplyr::group_by(title) %>%
        summarise(sum = sum(totalCostAmount), n = n())
    #cost_df<-contactPi_df[which(contactPi_df$totalCostAmount > input$gThresh),]
    # fullname <- "ABRAHAM, ALISON G"
    plot_ly(contactPi_sum, 
            labels = ~title, 
            values = ~sum, 
            type = 'pie') %>%
      layout(title = 'Funding Proportions',
             xaxis = list(showgrid = FALSE, 
                          zeroline = FALSE, 
                          showticklabels = FALSE),
             yaxis = list(showgrid = FALSE, 
                          zeroline = FALSE, 
                          showticklabels = FALSE)
      )
  }) 
  
  # SECOND REACTIVE PLOT
  ## Reactive plot: Credit bar chart
  output$grant_dot <- renderPlotly({
     input$goButton
    fullname = isolate(input$fullname)
    contactPi_keep <- grepl(pattern = paste0("^",fullname),
                            x = grant_df$contactPi,
                            ignore.case = TRUE)
    
    contactPi_df <- grant_df[contactPi_keep,]
    
    plot_ly(contactPi_df, 
            y = ~totalCostAmount,
            x = ~fy,
            type = 'scatter', 
            color = ~title,
            mode = 'markers',
            symbol = I(1),
            marker = list(size = 10,
                          fill = "none",
                       line = list(color = ~title,
                                   width = 2))) %>% 
      layout(title = "Funding Timeline", 
             showlegend = FALSE,
             yaxis = list(title = 'Dollars', 
                          tickcolor = toRGB("blue")),
             xaxis = list(title = 'Fiscal Year', 
                          autotick = FALSE, 
                          ticks = "outside", 
                          tick0 = 0, 
                          dtick = 1, 
                          ticklen = 5, 
                          tickwidth = 2, 
                          tickcolor = toRGB("blue")))
  })

  
}
  

  

# name
# affiliation + citationplot + yearpublication (title click get paper)
# + year + barplot 
