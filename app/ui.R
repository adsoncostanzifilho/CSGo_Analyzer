# ui ----
require(shiny)
require(shinydashboard)
require(shinydashboardPlus)

source('functions_app/csgo_api.R')

# set key
api_key <<- 'XXXXXX'

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
        fluidRow(
          column(
            width = 12,
            class = 'home_welcome',
            HTML('<h1>Welcome to the <b>CS Go Analiser</b></h1>')
          ),
          
          column(
            width = 12,
            hr()
          ),
          
          column(
            width = 12,
            class = 'search_go',
            box(
              textInput(
                inputId = 'user_id', 
                label = 'Please enter your Steam ID',
                value = '',
                placeholder = '76561198263364899')
            ),
            
            actionButton(
              inputId = 'go',
              label = 'GO',
              class = 'btn_go',
              icon = icon('skull')
            )
          ),
          
          uiOutput('user_info')
          
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
