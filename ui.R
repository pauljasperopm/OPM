library(shiny)
library(shinydashboard)
library(tidyverse)
library(lubridate)
library(DT)
library(shinyWidgets)

shinyUI(
  dashboardPage(
    dashboardHeader(title = "SENSA Dashboard",
                    tags$li(a(img(src = 'logo.jpg',
                                  title = "Company Home", height = "30px"),
                              style = "padding-top:10px; padding-bottom:10px;"),
                            class = "dropdown")),
    
    dashboardSidebar(
      # selectInput("dist",
      #             shiny::HTML("<p><span style='color: black'>Names of District </span></p>"),
      #             choices = c("Select District", levels(df$district)),
      #             selected = "Khairpur"),
      pickerInput("dist",
                  shiny::HTML("<p><span style='color: black'>Names of District </span></p>"),
                  choices= c("Karachi", "Khairpur", "Qamber Shahdadkot"),
                  options = list(`actions-box` = TRUE),multiple = T,
                  selected = c("Karachi", "Khairpur", "Qamber Shahdadkot")),
      sidebarMenu(
      menuItem("Main Dashboard", tabName = "main",
               icon = icon("tachometer")),
      menuItem("Student Information", tabName = "student",
               icon = icon("user-graduate")),
      menuItem("Enumerators Information", tabName = "enum",
               icon = icon("chalkboard-teacher"))
    )),
    dashboardBody(
      tags$head(tags$style(HTML('
                                /* logo */
                                .skin-blue .main-header .logo {
                                background-color: #002147;
                                }

                                /* navbar (rest of the header) */
                                .skin-blue .main-header .navbar {
                                background-color: #002147;
                                }
                                /* body */
                                .content-wrapper, .right-side {
                                background-color: #ffffff;
                                }

                                /* main sidebar */
                                .skin-blue .main-sidebar {
                                background-color: #A6A6A6;
                                }
 
                                /* other links in the sidebarmenu */
                                .skin-blue .main-sidebar a{
                                background-color: #A6A6A6;
                                color: #000000;
                                font-weight: bold;
                                }

                                /* Hovered side bar*/
                                .skin-blue .main-sidebar .sidebar .sidebar-menu a:hover{
                                background-color: #002147;
                                }

                                /* Active sidebar */
                                .skin-blue .main-sidebar .sidebar .sidebar-menu .active a{
                                background-color: #002147;
                                color: #ffffff;
                                }
                                '))),
      tabItems(
        tabItem(tabName = "main",
                ##########################
                # First row with numbers #
                ##########################
                fluidRow(
                  valueBoxOutput("value1"),
                  valueBoxOutput("value2"),
                  valueBoxOutput("value3")
                ),
                ##########################
                # Second row with graphs #
                ##########################
                fluidRow(
                  column(12,
                         plotOutput("histogram"))
                )
                ),
        tabItem(tabName = "student",
                ##########################
                # First row with numbers #
                ##########################
                fluidRow(
                  valueBoxOutput("value4"),
                  valueBoxOutput("value5"),
                  valueBoxOutput("value6")
                ),
                ##########################
                # Second row with graphs #
                ##########################
                fluidRow(
                  column(6,
                         plotOutput("mismatch")),
                  column(6,
                         plotOutput("absent"))
                )
        ),
        tabItem(tabName = "enum",
                h1("Enumerators Information"),
                fluidRow(
                  column(6,DT::dataTableOutput("etable"))
                )
                   )
      )

  )
  )
)