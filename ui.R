# install.packages("here")
# install.packages("shinydashboard")
library(here)
library(shiny)
library(ggplot2)
library(plotly)
library(readr)
library(shinydashboard)

course_grant_df <- read_rds(here("data/course_grant_df.rds"))

name_list <- course_grant_df$Fullname
department_list = course_grant_df$Department

body <- dashboardBody(
    # define HTML paragraph (p) tag styling with CSS
    tags$p(tags$style(HTML('
    p {
        font-family: "Georgia", Times, "Times New Roman", serif;
        font-weight: bold;
        font-size: 24px;
        text-align: center;
      }
    '))),
    fluidRow(
        box(title = list("Select Scholar",
                         shiny::icon("users")),
            width = 3,
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
                                              ', Citations',
                                              shiny::icon("quote-right"),
                                              ', or GitHub (link to code & data)',
                                              shiny::icon("github")
                                              ),
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
                        collapsible = TRUE,
                        width = 12),
                    tabBox(
                        # Title can include an icon
                        title = list(strong('App Info'), 
                                     shiny::icon("tablet")),
                        width = 12,
                        side = "right",

                tabPanel(title = "GitHub Tab", 

                        "The “GitHub” tab in the sidebar directs you to the GitHub page of the Scholar project where it provides all R codes and data files."),
                    tabPanel(title = "Grants Tab", 
                       "If you want to explore the scholar’s grants, you can select “Grants” in the sidebar.
                        
                        The “Grant” page provides two plots and one table. The plot on the left displays grant funding in dollars over years and the plot on the right displays the funding proportion of each project. Different colors are used to differentiate the funding projects. The funding table at the bottom of the page displays detailed information (project number, fiscal year, project title and total cost amount in dollars) about the project."
                    ),

                    tabPanel(title = "Citations Tab", 

                        "If you want to explore the scholar’s citations, you can select “Citations” in the sidebar. The “Citation” page similarly provides two plots and one table. The plot on the left displays the trend of total citations over years. The plot on the right displays the….. The citation table at the bottom of the page displays the top 10 most cited articles of the scholar."
                    ),

                    tabPanel(title = "Scholar App",
                        "The ‘Scholar’ shiny app helps you get information about citations, NIH/NSF grants and the teaching classes of faculty members at Johns Hopkins School of Public Health. You can first choose a department name and use slider bar to select the scholar you are interested in. After your selection, the information about the position of the scholar and the courses he or she has taught in 2017 would show up."
                        )
                    ),
                    box(title = list(strong('Data Collection'), 
                                     shiny::icon("smile-o")),
                        
                        "
                        Teaching Courses:
                        
                        The teaching information for the school year of 2017 - 2018 was obtained by scraping web data from the website of JHSPH faculty (https://www.jhsph.edu/faculty/directory/list/)). Through the process of reading HTML source file, removing non-faculty staff, and extracting the HTML “href” attribute, we have accessed to the URL of each faculty member’s teaching information, and then scraped the course lists from these websites.",
                        width = 12),
                    
                        box(title = list(strong('Citations'), 
                                         shiny::icon("smile-o")),
                            "
                        The data of citation were acquired from Google Scholar by using John Muschelli’s “gcite” R package. Citation information for faculty members of JHSPH who have Google Scholar profiles is collected. Data are stored in the form of R list of data frames with the citation information of each faculty member stored in a data frame. The data include titles of published articles, authors, publication dates, publisher, journal, total number of citations for each article and citation numbers in each year.",
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
                        plotlyOutput("grant_dot")),
                    box(title = list('Funding Proportions', 
                                     shiny::icon("pie-chart")),
                        width = 5,
                        solidHeader = TRUE,
                        collapsible = TRUE,
                        plotlyOutput("grant_pie"))), 
                fluidRow(
                    box(title = list('Funding Table', 
                                     shiny::icon("table")),
                        width = 12,
                        solidHeader = TRUE,
                        collapsible = TRUE,
                        htmlOutput("grant_tbl")))),
        # Second tab content
        tabItem(tabName = "citations",
                p("Citation Data"),
                fluidRow(
                    tabBox(
                        # Title can include an icon
                        title = list("Line Charts", 
                                     shiny::icon("line-chart")),
                        width = 7,
                        side = "right",
                        tabPanel("Citations",
                                 plotlyOutput("cite_dot")
                        ),
                        tabPanel("Publications",
                                 plotlyOutput("pub_dot")
                                 )
                    ),

                    box(title = list('Citations by Article', 
                                     shiny::icon("pie-chart")),
                        width = 5,
                        solidHeader = TRUE,
                        collapsible = TRUE,
                        plotlyOutput("cite_pie")
                    )), 
                fluidRow(
                    box(title = list('Citation Table', 
                                     shiny::icon("table")),
                        width = 12,
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
