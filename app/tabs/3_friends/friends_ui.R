#- PREDICTION TAB
friends <- tabItem(
  tabName = "friends",
  
  fluidRow(
    uiOutput('friends_welcome'),
  
    column(
      width = 12,
      class = 'home_welcome',
      
      uiOutput('compare_friends') %>%
        withLoader(type="image", loader="csgo_load.gif"), 
      
      uiOutput('dream_team')
    )
    
    
    )
)