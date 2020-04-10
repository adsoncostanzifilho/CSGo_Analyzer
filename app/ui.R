# ui ----
require(shiny)
require(shinydashboard)
require(shinydashboardPlus)


ui <- dashboardPagePlus(
  collapse_sidebar = TRUE,
  
  # PAGE NAME
  title = "CS Analyser", 
  
  
  # HEADER
  dashboardHeader(
    title = tags$img(src = 'img/cs_logo.PNG', class = 'main_logo')
  ),
  
  # SIDE BAR
  dashboardSidebar(
    sidebarMenu(
      menuItem("Home", tabName = "home", icon = icon("award")),
      menuItem("Descriptive", tabName = "descriptive", icon = icon("skull")),
      menuItem("Prediction", tabName = "prediction", icon = icon("skull")),
      menuItem("About", tabName = "about", icon = icon("address-card"))
    )
  ),
  
  # BODY
  dashboardBody(
    
    ## PAGE LOGO
    list(
      tags$head(
        HTML('<link rel="icon", href="img/caveira_icon.PNG",type="image/png" />'))),
    
    # THEME 
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")), 
    
    # TABS
    tabItems(
      
      #- HOME TAB
      tabItem(
        tabName = "home",
        
        fluidRow(h1('home')
        )
      ),
      
      #- DESCRIPTIVE TAB
      tabItem(
        tabName = "descriptive",
        
        fluidRow(
          h1('descriptive')
        )
      ),
      
      #- PREDICTION TAB
      tabItem(
        tabName = "prediction",
        
        fluidRow(
          h1('prediction')
        )
      ),
      
      #- ABOUT TAB
      tabItem(
        tabName = "about",
        
        fluidRow(
          h1('about')
        )
      )
    )
      
  )
)
