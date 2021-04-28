#- PREDICTION TAB
friends <- tabItem(
  tabName = "friends",
  
  uiOutput('whole_page_friends') %>%
    withLoader(type = "image", loader = "csgo_load.gif")
  
  
)