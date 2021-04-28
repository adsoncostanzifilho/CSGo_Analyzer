# ui ----
require(shiny)
require(shinydashboard)
require(shinydashboardPlus)
require(shinyhelper)
require(shinycustomloader)
require(shinycssloaders)
require(CSGo)
require(stringr)
require(tidyr)
require(dplyr)
require(highcharter)
require(plotly)

# set plan to collect the data app in parallel
future::plan(future::multisession, workers = parallel::detectCores())

# SET CREDENTIALS
source('credentials/api_key.R')


#- Loading UIs
source("tabs/1_home/home_ui.R")
source("tabs/2_me/me_ui.R")
source("tabs/3_friends/friends_ui.R")
source("tabs/4_about/about_ui.R")


# MAIN UI START
ui <- shinydashboardPlus::dashboardPage(
  
  # PAGE NAME
  title = "CS Analyzer", 
  
  
  # HEADER
  dashboardHeader(
    title = tags$img(src = 'img/cs_logo.PNG', class = 'main_logo')
  ),
  
  
  # SIDE BAR
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("award")),
      menuItem("Individual Data", tabName = "me", icon = icon("skull")),
      menuItem("Friends Data", tabName = "friends", icon = icon("book-dead")),
      menuItem("About", tabName = "about", icon = icon("bomb"))
    )
  ),
  
  
  # BODY
  dashboardBody(

    tags$head(
      
      # SCROLL FIX
      tags$style(
        HTML('.wrapper {heigth: auto !important; position: relative; overflow-x: hidden; overflow-y: hidden;')
      ),
      
      # PAGE LOGO
      HTML('<link rel="icon", href="img/caveira_icon.PNG", type="image/png" />'),
      
      # THEME 
      tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")
    ),
    
    
    #- Remove error messages
    tags$style(
      type="text/css",
      ".shiny-output-error { visibility: hidden; }",
      ".shiny-output-error:before { visibility: hidden; }"
    ),
    
    # TABS
    tabItems(
      home,
      me,
      friends,
      about
    ),
    
    # FOOTER
    tags$div(
      class = 'my_footer',
      tags$b('Powered by '), 
      tags$a(
        class = 'package_link',
        href="https://adsoncostanzifilho.github.io/CSGo/", 
        tags$b('CSGo package'))
    )
      
  )
)
