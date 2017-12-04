setwd("/Users/gege/Dropbox/graduate/DataScience/shiny")
library(shiny)
library(ggplot2)
# library(plotly)

shinyUI(
  navbarPage(
    titlePanel("Scholar"),
  
    sidebarLayout(
      sidebarPanel(
        # sliderInput("year", "Year", 1967, 2017, 100),
        textInput("first", "First Name"),
        textInput("last", "Last Name"),
        actionButton("goButton", "Go!")),
  
      mainPanel(
        tabsetPanel(type="tabs",
                    tabPanel("Information", br(), textOutput("name"), textOutput("department"), textOutput("title"), plotOutput("citeplot"), plotOutput("pubbar"), tags$head(tags$style("#name{color: black;font-size: 30px;}")), tags$head(tags$style("#department{color: black;font-size: 20px;}")), tags$head(tags$style("#title{color: black;font-size: 20px;}"))),
                    # font-style: italic;
                    tabPanel("Publication Detail", tableOutput("publication")),
                    tabPanel("Class", htmlOutput("class"), tags$head(tags$style("#class{color: black;font-size: 20px;}"))),
                    tabPanel("Grant", renderTable("grant"))
        )
      )
    )
  )
)