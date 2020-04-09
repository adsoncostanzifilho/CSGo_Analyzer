# ui ----
require(shiny)
require(shinydashboard)



ui <- dashboardPage(

  # PAGE NAME
  title = "CS Analyser", 
  
  
  # HEADER
  dashboardHeader(
    title = tags$img(src = 'img/cs_logo.PNG', class = 'main_logo')
  ),
  
  # SIDE BAR
  dashboardSidebar(
    collapsed = TRUE
  ),
  
  # BODY
  dashboardBody(
    
    ## PAGE LOGO
    list(
      tags$head(
        HTML('<link rel="icon", href="img/caveira_icon.PNG",type="image/png" />'))),
    
    # THEME 
    tags$head(tags$link(rel = "stylesheet", type = "text/css", href = "styles.css")), 
    
    
  )
)
