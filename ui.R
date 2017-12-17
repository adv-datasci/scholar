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
    tags$p(tags$style(HTML('
    p {
        font-family: "Georgia", Times, "Times New Roman", serif;
        font-weight: bold;
        font-size: 24px;
        text-align: center;
      }
    '))),
    fluidRow(
        box(title = list("Name (Last, First)",
                         shiny::icon("users")),
            width = 3,
            height = 100,
            solidHeader = TRUE,
            collapsible = TRUE, 
            selectInput("fullname", 
                        label = NULL, 
                        choices=name_list,
                        selected=2)
               ),
        box(title = list("Scholar Info",
                         shiny::icon("id-card")),
            width = 3,
            height = "auto",
            solidHeader = TRUE,
            collapsible = TRUE, 
            textOutput("department"), 
            textOutput("title")
               ),
        box(title = list("Courses Taught", 
                         shiny::icon("graduation-cap")),
            width = 6,
            height = "auto",
            solidHeader = TRUE,
            collapsible = TRUE, 
            htmlOutput("class"))),
    tabItems(
        # First tab content
        tabItem(tabName = "info",
                p("Quick Start Guide"), 
                fluidRow(
                    tags$div(align = "center",
                    box(title = list(strong('Step 1 -'),
                                     'Choose Sidebar Item: App Info',
                                     icon("info-circle"),
                                     ', Grants',
                                     shiny::icon("usd"), 
                                     ', or Citations',
                                     shiny::icon("quote-right")),
                        width = 12),
                    box(title = list(strong('Step 2 -'), 
                                     'Collapse Sidebar', 
                                     shiny::icon("bars")),
                        width = 4),
                    box(title = list(strong('Step 3 -'),
                                     'Choose Scholar', 
                                     shiny::icon("users")),
                        width = 4),
                    box(title = list(strong('Step 4 -'), 
                                     'Collapse a Box', 
                                     shiny::icon("minus")),
                        width = 4)
                    )),
                p("Contributions"), 
                fluidRow(
                    box(title = list(strong('Authors'), 
                                     shiny::icon("smile-o")),
                "The authors of the 'Scholar' shiny app are Gege Gui, Yue Cao, Shulin Qing, and Martin Skarzynski.",
                width = 12),
                box(title = list(strong('Contributors'), 
                                 shiny::icon("thumbs-o-up")),
"We would like to thank two amazing contributors to this project: John Muschelli and Stephen Cristiano. Both provided code snippets and guidance. For data scraping in particular, we relied heavily on packages created by John. For more information, please take a look at a list of packages and code snippets we used during the creation of the project below.",
                    width = 12)),
                p("Software"), 
                fluidRow(
                    box(title = list(strong('Packages'), 
                                     shiny::icon("dropbox")),
                "The used in the making of the 'Scholar' shiny app are readr (Hadley Wickham), shiny (Joe Cheng) ...",
                width = 12),
                box(title = list(strong('Code Snippets'), 
                                 shiny::icon("code")),
                    "The used in the making of the 'Scholar' shiny app are readr (Hadley Wickham), shiny (Joe Cheng) ...",
                    width = 12))
                ),
        tabItem(tabName = "grants",
            p("Grant Data"), 
            fluidRow(
                box(title = list("Funding Timeline", 
                                    shiny::icon("line-chart")),
                width = 7,
                solidHeader = TRUE,
                collapsible = TRUE, 
                height = 460,
                plotlyOutput("grant_dot")),
                box(title = list('Funding Proportions', 
                                    shiny::icon("pie-chart")),
                    width = 5,
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    height = 460,
                    plotlyOutput("grant_pie"))), 
            fluidRow(
                box(title = list('Funding Table', 
                                    shiny::icon("table")),
                    width = 12,
                    solidHeader = TRUE,
                    collapsible = TRUE,
                    height = "auto",
                    tableOutput("grant_tbl")))),
        # Second tab content
        tabItem(tabName = "citations",
                p("Citation Data"), 
                fluidRow(
                    box(title = list("Citation Timeline", 
                                     shiny::icon("line-chart")),
                        width = 7,
                        solidHeader = TRUE,
                        collapsible = TRUE, 
                        height = 460
                        # ,
                        # plotlyOutput("grant_dot")
                        ),
                    box(title = list('Citations by Journal', 
                                     shiny::icon("pie-chart")),
                        width = 5,
                        solidHeader = TRUE,
                        collapsible = TRUE,
                        height = 460
                        # ,
                        # plotlyOutput("grant_pie")
                        )), 
                fluidRow(
                    box(title = list('Citation Table', 
                                     shiny::icon("table")),
                        width = 12,
                        solidHeader = TRUE,
                        collapsible = TRUE,
                        height = "auto"
                        # ,
                        # tableOutput("grant_tbl")
                        ))
                )
        )
    )

dashboardPage(
    dashboardHeader(title = "Scholar",
                    titleWidth = 120),
    dashboardSidebar(width = 120,
        sidebarMenu(
            menuItem("App Info", tabName = "info", icon = icon("info-circle")),
            menuItem("Grants", tabName = "grants", icon = icon("usd")),
            menuItem("Citations", tabName = "citations", icon = icon("quote-right"))
    )),
    body
)