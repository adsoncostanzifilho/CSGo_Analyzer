#- DESCRIPTIVE TAB
me <- tabItem(
  tabName = "me",
  
  fluidRow(
    uiOutput('user_welcome'),
    
    uiOutput('main_kpis'),
    
    column(
      width = 12,
      class = 'home_welcome',
      uiOutput('weapon_ui'),
      
      uiOutput('map_ui')
    )
    
  )
)