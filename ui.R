# setwd("/Users/gege/Dropbox/graduate/DataScience/shiny")
# install.packages("here")
library(here)
library(shiny)
library(ggplot2)
library(plotly)
library(readr)

grant_df<-read_rds(here("data/grant_df.rds"))
course_df <- read_rds(here("data/course_df.rds"))

name_list <- course_df$Name
fluidPage(
    h2("Scholar", align = "center"),
    hr(),
    fluidRow(
        column(3,
               h4("Name (First, Last)"),
               selectInput("fullname", 
                           label=NULL,
                           choices=name_list,selected=2)
                           ),
        column(3, 
               h4("Scholar Information"),
               textOutput("department"), 
               textOutput("title")
               ),
        column(6,
               h4("Courses Taught"),
           htmlOutput("class"))),
    h3("Grant Data", align = "center"),
    hr(),
    fluidRow(
        column(8,
               plotlyOutput("grant_dot")),
        column(4,    
               plotlyOutput("grant_pie"))), 
    tableOutput("grant_tbl"),
    h3("Citation Data", align = "center"),
    hr())