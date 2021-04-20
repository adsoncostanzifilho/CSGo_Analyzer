# ui ----
require(shiny)
require(shinydashboard)
require(shinydashboardPlus)
require(dplyr)
require(shinyhelper)
require(CSGo)


source('credentials/api_key.R')


#- Loading UIs
source("tabs/1_home/home_ui.R")
source("tabs/2_me/me_ui.R")
source("tabs/3_friends/friends_ui.R")
source("tabs/4_about/about_ui.R")


ui <- shinydashboardPlus::dashboardPage(
  
  # PAGE NAME
  title = "CS Analyzer", 
  
  
  # HEADER
  dashboardHeader(
    title = tags$img(src = 'img/cs_logo2.PNG', class = 'main_logo')
  ),
  
  
  # SIDE BAR
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("award")),
      menuItem("Individual Data", tabName = "me", icon = icon("skull")),
      menuItem("Friends Data", tabName = "friends", icon = icon("skull")),
      menuItem("About", tabName = "about", icon = icon("book-dead"))
    )
  ),
  
  # BODY
  dashboardBody(

    tags$head(
      # PAGE LOGO
      HTML('<link rel="icon", href="img/caveira_icon.PNG",type="image/png" />'),
      
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
