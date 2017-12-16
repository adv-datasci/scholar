# setwd("/Users/gege/Dropbox/graduate/DataScience/shiny")
setwd("~/github/scholar/")
library(shiny)
library(ggplot2)
# library(plotly)
library(readr)
name_list<-read_rds("name_list.rds")
shinyUI(
  navbarPage(
    titlePanel("Scholar"),
    sidebarLayout(
      sidebarPanel(
        # sliderInput("year", "Year", 1967, 2017, 100),
        tabPanel("Researcher Menu",
                 selectInput("fullname", 
                             label="Scholar (Last Name, First Name)",
                             choices=name_list,selected=1)),
        actionButton("goButton", "Go!")),
      mainPanel(
        tabsetPanel(type="tabs",
                    tabPanel("Information", 
                             br(), 
                             textOutput("name"),
                             textOutput("index"),
                             textOutput("department"), 
                             textOutput("title"), 
                             #plotOutput("citeplot"), 
                             #plotOutput("pubbar"), 
                             tags$head(tags$style("#name{color: black;font-size: 30px;}")), 
                             tags$head(tags$style("#department{color: black;font-size: 20px;}")), 
                             tags$head(tags$style("#title{color: black;font-size: 20px;}"))),
                    # font-style: italic;
                    tabPanel("Publication(s)", 
                             tableOutput("publication")),
                    tabPanel("Course(s)", htmlOutput("class"), 
                             tags$head(tags$style("#class{color: black;font-size: 20px;}"))),
                    tabPanel("Grant(s)", 
                             br(),  plotlyOutput("grant_dot"),
                             br(), plotlyOutput("grant_pie"),
                             br(), tableOutput("grant_tbl"))
        )
      )
    )
  )
)