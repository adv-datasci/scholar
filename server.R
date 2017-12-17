library(shiny)
library(magrittr)
library(purrr)
library(plotly)
#install.packages("plotly")
library(here)
library(ggplot2)
library(stringr)
library(readr)
# Elizabeth Colantuoni

grant_df<-read_rds(here("data/grant_df.rds"))
course_df <- read_rds(here("data/course_df.rds"))

name_list <- course_df$Name

function(input, output) {
    output$name = renderText({
        fullname = input$fullname
        out = paste0("Name: ", fullname)
        print(out)
    })
    
    output$index = renderText({
        fullname = input$fullname
        index = which(name_list==fullname)[1]
        out = paste0("Index: ", index)
        print(out)
    })
    
    output$department = renderText({
        fullname = input$fullname
        index = which(name_list==fullname)[1]
        out = paste0("Department: ", as.character(course_df[index, 1]))
        print(out)
    })
    
    output$title = renderText({
        fullname = input$fullname
        index = which(name_list==fullname)[1]
        out = paste0("Position: ", as.character(course_df[index, 2]))
        print(out)
    })
    
    output$class = renderUI({
        fullname = input$fullname
        index = which(name_list==fullname)[1]
        allc = as.character(course_df[index, 6])
        allc = str_split(allc, pattern = fixed(", "), simplify = T)
    out <- str_c(allc, collapse = '<br/>')
    HTML(out)
  })
# need citations data to fix this part  
  output$publication = renderTable({
    fullname = input$fullname
    splitname = str_split(string = fullname, 
                          pattern = ", ")[[1]]
    l = splitname[1]
    f = splitname[2]
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,c(1,3)]
    print(t)
  })
# need citations data to fix this part  
  output$citeplot = renderPlot({
    fullname = input$fullname
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
# need citations data to fix this part  
  output$pubbar = renderPlot({
    fullname = input$fullname
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
# need citations data to fix this part  
  output$publication = renderTable({
    fullname = input$fullname
    splitname = str_split(string = fullname, 
                          pattern = ", ")[[1]]
    l = splitname[1]
    f = splitname[2]
    name = str_split(names(citation), pattern = fixed(" "), simplify = T)
    t = citation[[which(name[,1] == f & name[,2] == l)]][,c(1,3)]
    print(t)
  })

  output$grant_tbl = renderTable({
    fullname = input$fullname
    splitname = str_split(string = fullname,
                          pattern = ", ")[[1]] %>%
        toupper()
    l = splitname[1]
    f = str_split(string = splitname[2],
                  pattern = " ")[[1]][1]
    contactPi_keep <- grepl(pattern = paste0("^",l,", ",f),
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
    fullname = input$fullname
    splitname = str_split(string = fullname,
                          pattern = ", ")[[1]] %>%
                    toupper()
    l = splitname[1]
    f = str_split(string = splitname[2],
                  pattern = " ")[[1]][1]
    contactPi_keep <- grepl(pattern = paste0("^",l,", ",f),
                                 x = grant_df$contactPi,
                                 ignore.case = TRUE)
    contactPi_df <- grant_df[contactPi_keep,]
    contactPi_sum <- contactPi_df %>% dplyr::group_by(title) %>%
        summarise(sum = sum(totalCostAmount), n = n())
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
    fullname = input$fullname
    splitname = str_split(string = fullname,
                          pattern = ", ")[[1]] %>%
        toupper()
    l = splitname[1]
    f = str_split(string = splitname[2],
                  pattern = " ")[[1]][1]
    contactPi_keep <- grepl(pattern = paste0("^",l,", ",f),
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
  
