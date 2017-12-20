# install.packages("here")
# install.packages("shinydashboard")
library(here)
library(shiny)
library(ggplot2)
library(plotly)
library(readr)
library(shinydashboard)
library(markdown)

course_grant_df <- read_rds(here("data/course_grant_df.rds"))

name_list <- course_grant_df$Fullname
department_list = course_grant_df$Department

body <- dashboardBody(
    # define HTML paragraph (p) tag styling with CSS
    tags$h5(tags$style(HTML('
    h5 {
        margin: 1px;
        text-align: center;
        padding: 1px;
        font-family: "Georgia", Times, "Times New Roman", serif;
        font-weight: bold;
        font-size: 24px;
      }
    '))),
    fluidRow(
        box(title = list("Select Scholar",
                         shiny::icon("user")),
            width = 3,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE, 
            selectInput("departmentname", 
                        label = "Department", 
                        choices = department_list, 
                        selected = 1), 
            selectInput("fullname", 
                        label = "Name (Last, First)",
                        choices=name_list,
                        selected=2)
        ),
        box(title = list("Scholar Stats",
                         shiny::icon("id-card")),
            width = 3,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE, 
            textOutput("position"), 
            textOutput("total_grant_count"), 
            textOutput("total_grant_amount"),
            textOutput("total_cites"), 
            textOutput("total_pubs") 
        ),
        box(title = list("Courses Taught in 2017", 
                         shiny::icon("graduation-cap")),
            width = 6,
            status = "primary",
            solidHeader = TRUE,
            collapsible = TRUE,
            
            htmlOutput("class"))
        ),
    tabItems(
        # First tab content
        tabItem(
# reset whitespace in info tab
tabName = "info",
h5("Quick Start Guide"), 
fluidRow(
    tags$div(align = "center",
             box(title = list(strong('Step 1 -'),
                              'Choose Sidebar Item: App Info',
                              icon("info-circle"),
                              ', Grants',
                              shiny::icon("usd"), 
                              ', Citations',
                              shiny::icon("quote-right"),
                              ', or GitHub (link to code & data)',
                              shiny::icon("github")
                              ),
                status = "primary",
                collapsible = TRUE,
                collapsed = TRUE,
                 width = 12))
),
fluidRow(
             box(title = list(strong('Step 2 -'), 
                              'Collapse Sidebar', 
                              shiny::icon("bars")),
                status = "primary",
                collapsible = TRUE,
                collapsed = TRUE,
                 width = 4),
             box(title = list(strong('Step 3 -'),
                              'Choose Scholar', 
                              shiny::icon("user")),
                status = "primary",
                collapsible = TRUE,
                collapsed = TRUE,
                 width = 4),
             box(title = list(strong('Step 4 -'), 
                              'Collapse Box', 
                              shiny::icon("minus")),
                status = "primary",
                collapsible = TRUE,
                collapsed = TRUE,
                 width = 4)
),
fluidRow(
    tabBox(
        # Title can include an icon
        title = list(strong('App Info'), 
                     shiny::icon("info-circle")),
        width = 12,
        side = "right",
        selected = 1,
        
        tabPanel(title = list(strong("GitHub Tab"), 
                      shiny::icon("github")), 
                includeMarkdown(here("md/04_github-tab.md"))
                 ),
        
        tabPanel(title = list(strong("Grants Tab"), 
                          shiny::icon("usd")), 
                 includeMarkdown(here("md/03_grants-tab.md"))
    ),

        tabPanel(title = list(strong("Citations Tab"), 
                          shiny::icon("quote-right")),
                 includeMarkdown(here("md/02_citations-tab.md"))
    ),

        tabPanel(title = list(strong('Scholar App'), 
                          shiny::icon("tablet")),
                 value = 1,
                 includeMarkdown(here("md/01_scholar-app.md"))
        )
    )
),
h5("Methods"), 
fluidRow(
    tabBox(
        # Title can include an icon
        title = list(strong('Data Collection'), 
                     shiny::icon("database")),
        width = 12,
        side = "right",
        selected = 1,
        tabPanel(title = list(strong('JHSPH Faculty'), 
                         shiny::icon("globe")),
                 includeMarkdown(here("md/07_jhsph-faculty.md"))
            ),
        
        tabPanel(title = list(strong('NIH RePORTER'), 
                              shiny::icon("search")),
                 includeMarkdown(here("md/06_nih-reporter.md"))
        ),
            tabPanel(title = list(strong('Google Scholar'), 
                             shiny::icon("google")),
                     value = 1,
                 includeMarkdown(here("md/05_google-scholar.md"))
                )
    )
),
fluidRow(
        tabBox(
            title = list(strong('Software'), 
                         shiny::icon("code")),
            width = 12,
            side = "right",
            selected = 1,
            tabPanel(title = list(strong('Bugs'), 
                                  shiny::icon("bug")),
                 includeMarkdown(here("md/11_bugs.md"))
            ),
        tabPanel(title = list(strong('Packages'), 
                         shiny::icon("dropbox")),
                 includeMarkdown(here("md/10_packages.md"))
            ),
        tabPanel(title = list(strong('Contributors'), 
                              shiny::icon("thumbs-o-up")),
                 includeMarkdown(here("md/09_contributors.md"))
                 ),
        tabPanel(title = list(strong('Authors'), 
                         shiny::icon("users")),
                 value = 1,
                 includeMarkdown(here("md/08_authors.md"))
            )
        )
)),
# Done with info tab
            tabItem(tabName = "grants",
                fluidRow(
                    h5("Grant Data"), 
                        box(title = list("Funding Timeline", 
                                         shiny::icon("line-chart")),
                            width = 7,
                            status = "primary",
                            solidHeader = TRUE,
                            collapsible = TRUE, 
                            plotlyOutput("grant_dot")
                        ),
                        box(title = list('Funding Proportions', 
                                         shiny::icon("pie-chart")),
                            width = 5,
                            status = "primary",
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            plotlyOutput("grant_pie")
                        ), 
                        box(title = list('Funding Table', 
                                         shiny::icon("table")),
                            width = 12,
                            status = "primary",
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            htmlOutput("grant_tbl")
                            )
)),
            # Second tab content
            tabItem(tabName = "citations",
                    h5("Citation Data"),
                    fluidRow(
                        tabBox(
                            # Title can include an icon
                            title = list("Line Charts", 
                                         shiny::icon("line-chart")),
                            width = 7,
                            selected = 1,
                            side = "right",
                            tabPanel("Publications",
                                     plotlyOutput("pub_dot")
                                     ),
                            tabPanel("Citations",
                                     plotlyOutput("cite_dot"),
                                     value = 1
                            )
                        ),
    
                        box(title = list('Top 10 Most Cited Articles', 
                                         shiny::icon("pie-chart")),
                            width = 5,
                            status = "primary",
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            plotlyOutput("cite_pie")
                        )), 
                    fluidRow(
                        box(title = list('Top 10 Most Cited Articles', 
                                         shiny::icon("table")),
                            width = 12,
                            status = "primary",
                            solidHeader = TRUE,
                            collapsible = TRUE,
                            htmlOutput("pub_tbl")
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
            menuItem("Citations", tabName = "citations", icon = icon("quote-right")),
            menuItem("Grants", tabName = "grants", icon = icon("usd")),
            menuItem("GitHub", href = "https://github.com/adv-datasci/scholar/", icon = icon("github"))
    )),
    body
)
