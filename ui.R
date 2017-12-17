# setwd("/Users/gege/Dropbox/graduate/DataScience/shiny")
# install.packages("here")
# install.packages("shinydashboard")
library(here)
library(shiny)
library(ggplot2)
library(plotly)
library(readr)
library(shinydashboard)

grant_df<-read_rds(here("data/grant_df.rds"))
course_df <- read_rds(here("data/course_df.rds"))

name_list <- course_df$Name

body <- dashboardBody(
    fluidRow(
        box(title = "Name (First, Last)",
            width = 3,
            solidHeader = TRUE,
            collapsible = TRUE, 
            selectInput("fullname", 
                        label = NULL, 
                        choices=name_list,
                        selected=2)
               ),
        box(title = "Scholar Information",
            width = 3,
            solidHeader = TRUE,
            collapsible = TRUE, 
            textOutput("department"), 
            textOutput("title")
               ),
        box(title = "Courses Taught",
            width = 6,
            solidHeader = TRUE,
            collapsible = TRUE, 
            htmlOutput("class"))),
    h3("Grant Data", align = "center"),
    fluidRow(
        box(title = 'Funding Timeline',
        width = 8,
        solidHeader = TRUE,
        collapsible = TRUE, 
        plotlyOutput("grant_dot")),
        box(title = 'Funding Proportions',
            width = 4,
            solidHeader = TRUE,
            collapsible = TRUE, 
            plotlyOutput("grant_pie"))), 
    fluidRow(
        box(title = 'Funding Table',
            width = 12,
            solidHeader = TRUE,
            collapsible = TRUE, 
            tableOutput("grant_tbl"))),
    h3("Citation Data", align = "center"),
    hr())

dashboardPage(
    dashboardHeader(title = "Scholar"),
    dashboardSidebar(
        sidebarMenu(
            menuItem("Dashboard", tabName = "dashboard", icon = icon("dashboard")),
            menuItem("Widgets", tabName = "widgets", icon = icon("th"))
    )),
    body
)
# h2("Scholar", align = "center"),
# hr(),