library(shiny)
library(magrittr)
library(purrr)
library(plotly)
#install.packages("plotly")
# install.packages("kableExtra")
library(kableExtra)
library(knitr)
library(here)
library(ggplot2)
library(stringr)
library(readr)

course_grant_df <- read_rds(here("data/course_grant_df.rds"))

cite_df_list <- read_rds(here("data/cite_df_list_matched.rds"))

name_list <- course_grant_df$Fullname

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
        out = paste0("Department: ", as.character(course_grant_df[index, "Department"]))
        print(out)
    })
    
    output$title = renderText({
        fullname = input$fullname
        index = which(name_list==fullname)[1]
        out = paste0("Position: ", as.character(course_grant_df[index, "Position"]))
        print(out)
    })
    
    output$class = renderUI({
        fullname = input$fullname
        index = which(name_list==fullname)[1]
        allc = as.character(course_grant_df[index, "coursename"])
        allc = str_split(allc, pattern = fixed(", "), simplify = T)
        out <- str_c(allc, collapse = '<br/>')
        HTML(out)
    })
    output$pub_tbl = renderUI({
        fullname = input$fullname
        cite_df_list[[fullname]] %>% 
            dplyr::select(title,
                          # authors,
                          # publication.date,
                          # total.citations,
                          journal
                          ) %>% 
            kable(format = "html") %>%
        kable_styling(bootstrap_options = c("striped", 
                                            "hover", 
                                            "condensed", 
                                            "responsive")) %>% 
            HTML()
    })
    output$cite_dot = renderPlotly({
        fullname = input$fullname
        df <- cite_df_list[[fullname]]
        citey <- df[,12:ncol(df)-1]
        cy <- data.frame(names(citey), colSums(citey,na.rm = TRUE))
        colnames(cy) = c("x", "y")
        p <- ggplot(data = cy, aes(x, y, group = 1)) + geom_point() + geom_line() + labs(x = "Year", y = "Total Citations")
        ggplotly(p)
    })

    output$cite_pie <- renderPlotly({
        fullname = input$fullname
        df <- cite_df_list[[fullname]]
        names(df)[7] <- "total_cites"
        df %>% 
        plot_ly(
                labels = ~title, 
                values = ~total_cites, 
                type = 'pie') %>%
            layout(xaxis = list(showgrid = FALSE, 
                                zeroline = FALSE, 
                                showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, 
                                zeroline = FALSE, 
                                showticklabels = FALSE)
            )
    })    
    output$grant_tbl = renderUI({
        course_grant_df %>%
            dplyr::filter(Fullname == input$fullname) %>% 
            dplyr::select(projectNumber,
                          fy,
                          title,
                          totalCostAmount) %>% 
            kable(format = "html") %>%
        kable_styling(bootstrap_options = c("striped", 
                                            "hover", 
                                            "condensed", 
                                            "responsive")) %>% 
            HTML()
    })
    
    # FIRST REACTIVE PLOT
    ## Reactive plot: Grant funding pie chart
    output$grant_pie <- renderPlotly({
        contactPi_sum <- course_grant_df %>% 
            dplyr::filter(Fullname == input$fullname) %>% 
            dplyr::group_by(title) %>%
            summarise(sum = sum(totalCostAmount), n = n())
        plot_ly(contactPi_sum, 
                labels = ~title, 
                values = ~sum, 
                type = 'pie') %>%
            layout(xaxis = list(showgrid = FALSE, 
                                zeroline = FALSE, 
                                showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, 
                                zeroline = FALSE, 
                                showticklabels = FALSE)
            )
    }) 
    
    # SECOND REACTIVE PLOT
    ## Reactive plot: Grant scatter plot
    output$grant_dot <- renderPlotly({
        course_grant_df %>% 
            dplyr::filter(Fullname == input$fullname) %>% 
            plot_ly(
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
            layout(showlegend = FALSE,
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
  
