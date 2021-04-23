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
weapon_stats <- eventReactive(input$go, {
  
  weapon_stats <- user_stats() %>%
    filter(type == ' weapon info') %>%
    mutate(
      stat_type = case_when(
        str_detect(name, "shots") ~ "shots",
        str_detect(name, "hits") ~ "hits",
        str_detect(name, "kills") ~ "kills"
      )
    ) %>% 
    pivot_wider(
      names_from = stat_type, 
      id_cols = c(name_match, category), 
      values_from = value
    ) %>%
    mutate_if(is.numeric, replace_na, 0) %>%
    left_join(weapon_pictures, by = c('name_match'='weapon_name')) %>%
    filter(category != 'utilitario', category != 'suporte') %>%
    mutate(
      category = case_when(
        category == 'pistola' ~ 'Pistols',
        category == 'pesada' ~ 'Heavy',
        category == 'submetralhadora' ~ 'SMGs',
        category == 'rifle' ~ 'Rifles'
      )
    )
  
  return(weapon_stats)
  
})

weapon_plot <- reactive({
  
  weapon_stats <- weapon_stats()
  
  plot <- hchart(
    weapon_stats,
    "point",
    hcaes(
      x = shots, 
      y = hits, 
      name = name_match, 
      group = category,
      size = kills)
  ) %>%
    hc_tooltip(
      useHTML = TRUE,
      formatter = JS(
        'function () { 
          return "Weapon: " + "<b>" + this.point.name + "</b>"  
          + " <hr>" 
          + "<div><img src=" + this.point.weapon_photo + " class=weapon_img ></img></div>"
          + " <br/> Hits: " + "<b>" + this.point.hits + "</b>" 
          + " <br/> Shots: " + "<b>" + this.point.x + "</b>" 
          + " <br/> Kills: " + "<b>" + this.point.kills + "</b>" 
        ;}'
      )
    ) %>%
    hc_colors(
      colors = c(
        "#5d79ae",
        "#0c0f12",
        "#ccba7c",
        "#413a27")
    ) %>%
    hc_xAxis(title = list(text = "Shots")) %>%
    hc_yAxis(title = list(text = "Hits")) 
    # hc_theme(
    #   style = list(fontFamily = "Quantico")
    # )
  
  
  return(plot)
  
})

weapon_description <- reactive({
  
  weapon_stats <- weapon_stats() %>%
    mutate(
      shots_hit = round(hits/shots*100, 2),
      shots_kill = round(kills/shots*100, 2)
    ) 
  
  shots_hit <- weapon_stats %>%
    top_n(n = 2, wt = shots_hit) 
  
  shots_kill <- weapon_stats %>%
    top_n(n = 2, wt = shots_kill) 
  
  weapon_description <- shinydashboard::box(
    width = 10,
    h3("Choose the Best Weapon"),
    br(),
    h4(tags$b(shots_hit$shots_hit[1], "%"), "of your shots using the", tags$b(shots_hit$name_match[1]), "will hit.", class = "h4_left"),
    h4(tags$b(shots_hit$shots_hit[2], "%"), "of your shots using the", tags$b(shots_hit$name_match[2]), "will hit.", class = "h4_left"),
    h4(tags$b(shots_kill$shots_hit[1], "%"), "of your shots using the", tags$b(shots_kill$name_match[1]), "will kill.", class = "h4_left"),
    h4(tags$b(shots_kill$shots_hit[2], "%"), "of your shots using the", tags$b(shots_kill$name_match[2]), "will kill.", class = "h4_left")
  )
  
  
})

weapon <- eventReactive(input$go, {
  weapon_ui <- column(
    width = 6,
    class = "side_side",
    h1("Weapon Analysis"),
    shinydashboard::box(
      width = 12,
      highchartOutput('weapon_plot'),
      uiOutput("weapon_description")
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
    class = "box_map_desc",
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
      br(),
      uiOutput('map_picture'),
      br(),
      uiOutput("map_description")
      
    )
  )
  test <<- input$map_selector
  return(map_ui)
})









# OUTPUTS
output$user_welcome <- renderUI(user_welcome())

output$main_kpis <- renderUI(main_kpis())

output$weapon_plot <- renderHighchart(weapon_plot())
output$weapon_description <- renderUI(weapon_description())
output$weapon_ui <- renderUI(weapon())


output$map_picture <- renderUI(map_picture())
output$map_description <- renderUI(map_description())
output$map_ui <- renderUI(map())
