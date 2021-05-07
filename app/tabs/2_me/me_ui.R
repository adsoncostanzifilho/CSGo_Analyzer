#- DESCRIPTIVE TAB
me <- tabItem(
  tabName = "me",
  
  fluidRow(
    uiOutput('user_welcome') %>%
      shinycustomloader::withLoader(type = "html", loader = "loader3"),
      #shinycssloaders::withSpinner(type = 7, color = "#ce8404"),
    
    uiOutput('main_kpis'),
    
    column(
      width = 12,
      class = 'home_welcome',
      uiOutput('weapon_ui'),
      
      uiOutput('map_ui')  
    )
    
  )
)