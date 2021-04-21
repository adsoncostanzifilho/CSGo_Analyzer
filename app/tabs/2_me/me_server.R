# USER WELCOME
user_welcome <- eventReactive(input$go, {
  
  db_profile <- user_profile()

  welcome <- column(
    width = 12,
    class = 'home_welcome',
    tags$div(
      class = "one",
      tags$a(href = db_profile$profileurl, tags$img(class = "user_img", src = db_profile$avatarfull)),
      h1(tags$b(db_profile$personaname))
    ),
    br(),
    hr()
  )
  
  return(welcome)
})

# USER STATS
user_stats <- eventReactive(input$go, {
  
  # user_stats <- get_stats_user(api_key = api_key, user_id = '76561198263364899')
  user_stats <- get_stats_user(api_key = api_key, user_id = input$user_id)
})


# USER MAIN KPIs
main_kpis <- eventReactive(input$go, {
  
  user_stats <- user_stats()
  
 kpi <- column(
   width = 12,
   class = 'home_welcome',
   
   column(
     width = 3,
     class = "side_side",
     valueBox(
       width = 10,
       value = formatC(
         round(filter(user_stats, name == 'total_kills') %>% .$value /
           filter(user_stats, name == 'total_deaths') %>% .$value, 2),
         big.mark=','
       ),
       subtitle = "Kills / Deaths",
       icon = icon("skull-crossbones"),
       color = "purple")
   ),
   
   column(
     width = 3, 
     class = "side_side",
     valueBox(
       width = 10,
       value = formatC(
         user_stats %>%
           filter(name == 'total_mvps') %>%
           .$value,
         big.mark=','
       ),
       subtitle = "Total MVPs",
       icon = icon("crosshairs"),
       color = "purple")
   ),
   
   column(
     width = 3,
     class = "side_side",
     valueBox(
       width = 10,
       value = formatC(
         user_stats %>%
           filter(name == 'total_wins') %>%
           .$value,
         big.mark=','
       ),
       subtitle = "Total Wins",
       icon = icon("trophy"),
       color = "purple")
   ),
   
   column(
     width = 3,
     class = "side_side",
     valueBox(
       width = 10,
       value = formatC(
         user_stats %>%
           filter(name == 'total_time_played') %>%
           .$value,
         big.mark=','
       ),
       subtitle = "Time Played",
       icon = icon("clock"),
       #icon = icon("stats", lib='glyphicon'),
       color = "purple")
   )

 )
  
  
  return(kpi)
  
})


# WEAPON ANALYSIS
weapon <- eventReactive(input$go, {
  weapon_ui <- column(
    width = 6,
    class = "side_side",
    h1("Weapon Analysis"),
    shinydashboard::box(
      width = 12
    )
  )
  
  return(weapon_ui)
})


# MAP ANALYSIS
map_stats <- eventReactive(input$go, {
  aux <- user_stats() %>%
    filter(type == 'maps', name_match == 'dust2') 
  
  map_stats <- user_stats() %>%
    filter(type == 'maps') %>%
    anti_join(aux, by = c("value"="value")) %>%
    bind_rows(aux) %>%
    mutate(
      stat_type = case_when(
        str_detect(name, "win") ~ "win",
        str_detect(name, "won") ~ "won",
        str_detect(name, "rounds") ~ "rounds"
      ) 
    ) %>%
    distinct(name_match, stat_type, value) %>%
    pivot_wider(
      names_from = stat_type, 
      id_cols = name_match, 
      values_from = value
    ) %>%
    mutate_if(is.numeric, replace_na, 0) %>%
    mutate(
      win = win + won,
      perc = round(win/rounds*100,2)) %>%
    select(-won) %>%
    arrange(desc(perc))
  
  return(map_stats)
})

map_picture <- reactive({
  picture <- tags$image(
    class = "map_img",
    src = map_pictures %>% filter(map_name == input$map_selector) %>% .$map_photo
  )
  return(picture)
})

map_description <- reactive({
  map_stats <- map_stats() %>%
    filter(name_match == input$map_selector)
  
  map_description <- shinydashboard::box(
    width = 10,
    h3("Percentage of Wins:", tags$b(paste0(map_stats$perc, "%"))),
    h3("Number of Ronds:", tags$b(map_stats$rounds)),
    h3("Number of Wins:", tags$b(map_stats$win))
  )
  
  return(map_description)
})

map <- eventReactive(input$go, {
  choices_ordered <- map_stats() %>% .[[1]]
  
  map_ui <-  column(
    width = 6,
    class = "side_side",
    h1("Map Analysis"),
    shinydashboard::box(
      width = 12,
      selectInput(
        width = '50%',
        inputId = 'map_selector',
        label = "Choose a map",
        choices = choices_ordered,
        selected = choices_ordered[1],
        multiple = FALSE
      ),
      
      uiOutput('map_picture'),
      uiOutput("map_description")
    )
  )
  test <<- input$map_selector
  return(map_ui)
})









# OUTPUTS
output$user_welcome <- renderUI(user_welcome())
output$main_kpis <- renderUI(main_kpis())
output$weapon_ui <- renderUI(weapon())
output$map_picture <- renderUI(map_picture())
output$map_description <- renderUI(map_description())
output$map_ui <- renderUI(map())

