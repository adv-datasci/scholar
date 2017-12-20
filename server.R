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

course_grant_df <- read_rds(here("course_grant_df.rds"))

cite_df_list <- read_rds(here("cite_df_list.rds"))

name_list <- course_grant_df$Fullname
department_list <- course_grant_df$Department

function(input, output, session) {
    
    observe({
        de = input$departmentname
        newname_list = course_grant_df[which(course_grant_df$Department == de), "Fullname"]
        updateSelectInput(session, "fullname", choices = newname_list, label="Name (Last, First)")
    })
    
    output$position = renderText({
        fullname = input$fullname
        grant = course_grant_df[which(course_grant_df$Fullname == fullname), ]
        pos = grant[, "Position"][1]
        out = paste0("Position: ", pos)
        print(out)
    })
    
    output$total_grant_count = renderText({
        fullname = input$fullname
        grant = course_grant_df[which(course_grant_df$Fullname == fullname), ]
        grant_count = nrow(grant)
        out = paste0("Total Grants: ", grant_count)
        print(out)
    })
    
    output$total_grant_amount = renderText({
        fullname = input$fullname
        grant = course_grant_df[which(course_grant_df$Fullname == fullname), ]
        grant_amount = sum(grant$totalCostAmount)
        out = paste0("Total Grant Funding: ", grant_amount)
        print(out)
    })
    
    output$total_cites = renderText({
        fullname = input$fullname
        t = cite_df_list[[fullname]]
        t = t[, colnames(t) %in% regmatches(colnames(t),regexpr("X\\d{4}",colnames(t)))]
        colnames(t) = str_split(colnames(t), pattern = fixed("X"), simplify = T)[,2]
        cites = sum(t)
        out = paste0("Total Citations: ", cites)
        print(out)
    })
    
    output$total_pubs = renderText({
        fullname = input$fullname
        t = cite_df_list[[fullname]]
        t = t[, colnames(t) %in% regmatches(colnames(t),regexpr("X\\d{4}",colnames(t)))]
        colnames(t) = str_split(colnames(t), pattern = fixed("X"), simplify = T)[,2]
        pubs = nrow(t)
        out = paste0("Total Publications: ", pubs)
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
    output$pub_tbl = DT::renderDataTable({
        fullname = input$fullname
        t = cite_df_list[[fullname]]
        pcite = t[, colnames(t) %in% regmatches(colnames(t),regexpr("X\\d{4}",colnames(t)))]
        colnames(pcite) = str_split(colnames(pcite), pattern = fixed("X"), simplify = T)[,2]
        pcite = rowSums(pcite)
        t = cbind(t, pcite)
        t = t[order(t$pcite, decreasing = T), ]
        if (sum(colnames(t) == "publication.date.1") == 1){
            t$publication.date = t$publication.date.1
        }
        t <- t %>% dplyr::select("title", "publisher", "journal","publication.date", "pcite") %>% 
            unique()
        rownames(t) <- 1:nrow(t)
        colnames(t) = c("Article Title", "Publisher", "Journal", "Date", "Citations")
        t %>%
            DT::datatable()
    })
    output$cite_dot = renderPlotly({
        fullname = input$fullname
        t <- cite_df_list[[fullname]]
        t = t[, colnames(t) %in% regmatches(colnames(t),regexpr("X\\d{4}",colnames(t)))]
        colnames(t) = str_split(colnames(t), pattern = fixed("X"), simplify = T)[,2]
        citey = colSums(t)
        cy = data.frame(as.numeric(names(citey)), citey)
        colnames(cy) = c("x", "y")
        if (nrow(cy) < 7){
            k = 1
        } else if (nrow(cy) < 15){
            k = 2
        }else if (nrow(cy) < 22){
            k = 3
        }else {
            k = 5
        }
        p = ggplot(data = cy, aes(x, y, group = 1)) + geom_point(color = "#F8766D") + geom_line(color = "#F8766D") + labs(x = "Year", y = "Total Citation", title = "Total Citations By Year") + theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank(), axis.line = element_line(colour = "black")) + scale_x_continuous(breaks=seq(min(cy$x), max(cy$x), by = k))
        ggplotly(p)
    })
    output$pub_dot = renderPlotly({
        fullname = input$fullname
        t <- cite_df_list[[fullname]]
        if (sum(colnames(t) == "publication.date.1") == 1){
            t$publication.date = t$publication.date.1
        }
        t = t$publication.date
        t = t[!is.na(t)]
        yr = data.frame(str_split(t, pattern = fixed("/"), simplify = T)[,1])
        yr = table(yr)
        yr = data.frame(as.numeric(names(yr)), yr)
        colnames(yr) = c("x", "name", "y")
        if (nrow(yr) < 7){
            k = 1
        } else if (nrow(yr) < 15){
            k = 2
        }else if (nrow(yr) < 22){
            k = 3
        }else {
            k = 5
        }
        p = ggplot(data = yr, aes(x, y, group = 1)) + geom_point(color = "#619CFF") + geom_line(color = "#619CFF") + labs(x = "Year", y = "Total Publication", title = "Total Publication By Year")+theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(),panel.background = element_blank(), axis.line = element_line(colour = "black")) + scale_x_continuous(breaks=seq(min(yr$x), max(yr$x), by = k))
        ggplotly(p)
    })
    output$cite_pie <- renderPlotly({
        fullname = input$fullname
        t <- cite_df_list[[fullname]]
        pcite = t[, colnames(t) %in% regmatches(colnames(t),regexpr("X\\d{4}",colnames(t)))]
        colnames(pcite) = str_split(colnames(pcite), pattern = fixed("X"), simplify = T)[,2]
        pcite = rowSums(pcite)
        t = cbind(t, pcite)
        t = t[order(t$pcite, decreasing = T), ]
        t = t[1:10, ]
        if (sum(colnames(t) == "publication.date.1") == 1){
            t$publication.date = t$publication.date.1
        }
        out = t[, colnames(t) %in% c("title", "publication.date", "publisher", "journal", "pcite")]
        out = cbind(1:10, out)
        # colnames(out) = c("ID", "Title", "Publisher", "Journal", "Publication Date", "Total Citations")
        out %>% 
        plot_ly(
                labels = ~title, 
                values = ~pcite, 
                type = 'pie') %>%
            layout(xaxis = list(showgrid = FALSE, 
                                zeroline = FALSE, 
                                showticklabels = FALSE),
                   yaxis = list(showgrid = FALSE, 
                                zeroline = FALSE, 
                                showticklabels = FALSE)
            )
    })    
    output$grant_tbl <- DT::renderDataTable({
        out <- course_grant_df %>%
            dplyr::filter(Fullname == input$fullname) 
        out <- out[order(out$totalCostAmount, decreasing = T), ] %>%
            dplyr::select(projectNumber,
                          fy,
                          title,
                          totalCostAmount)  %>% unique()
            rownames(out) <- 1:nrow(out)
            colnames(out) = c("Number", "Year", "Title", "Amount")
            out  %>% 
            DT::datatable()
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
  
