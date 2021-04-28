#- DESCRIPTIVE TAB
me <- tabItem(
  tabName = "me",
  
  fluidRow(
    uiOutput('user_welcome'),
    
    uiOutput('main_kpis') %>%
      withSpinner(type = 7, color = "#ce8404"),
    
    column(
      width = 12,
      class = 'home_welcome',
      uiOutput('weapon_ui'),
      
      uiOutput('map_ui')  
    )
    
  )
)