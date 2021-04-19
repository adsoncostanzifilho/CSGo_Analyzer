#- HOME TAB 
home <- tabItem(
  tabName = "home",
  
  fluidRow(
    column(
      width = 12,
      class = 'home_welcome',
      HTML('<h1>Welcome to the <b>CS Go Analyzer</b></h1>'),
      h3("Here you will be able to collect your CSGO data and compare your skils with your friends!")
    ),
    
    column(
      width = 12,
      hr()
    ),
    
    column(
      width = 12,
      class = 'search_go',
      shinydashboard::box(
        textInput(
          inputId = 'user_id', 
          label = 'Please enter your Steam ID',
          value = '',
          placeholder = 'generalcapivara OR 76561198263364899') %>%
          helper(
            icon = "question",
            colour = "#ce8404",
            type = "inline",
            title = "Where can I find my Steam ID?",
            content = c(
              "Steam ID is the <b>NUMBER OR NAME</b> at the end of your steam profile URL.",
              "",
              "<b>Example</b>:",
              "Steam profile URL: <b>https://steamcommunity.com/profiles/76561198263364899/</b>,
                    in this case the Steam ID is <b>76561198263364899</b>.",
              "",
              "Steam profile URL: <b>https://steamcommunity.com/id/generalcapivara/</b>,
                    in this case the Steam ID is <b>generalcapivara</b>."
            ),
            buttonLabel = 'Got it!')
      )
    ),
    
    column(
      width = 12,
      class = "home_welcome",
      actionButton(
        inputId = 'go',
        label = 'GO',
        class = 'btn_go',
        icon = icon('skull')
      )
    ),

    
    br(),
    
    uiOutput('user_info')
    
  )
  
  
)