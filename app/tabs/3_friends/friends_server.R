#-- FRIENDS SERVER --#

# FRIENDS WELCOME
friends_welcome <- eventReactive(input$go, {
  
  db_profile <- user_profile()
  
  welcome <- column(
    width = 12,
    class = 'home_welcome',
    h1("Friends of ", db_profile$personaname),
    br(),
    hr()
  )
  
  return(welcome)
})


# FRIENDS STATS
friends_stats <- eventReactive(input$go, {
  
  # Get data
  user_profile <- user_profile()
  user_stats <- user_stats()
  friends <- get_stats_friends(api_key = api_key, user_id = input$user_id)
  
  # Bind Individual rows to the friends data
  friends_profile <- friends$friends %>%
    bind_rows(user_profile %>% select(steamid, personaname, profileurl, avatarfull))
  
  # Join profile variables
  friends_stats <- friends$friends_stats %>%
    bind_rows(user_stats) %>%
    left_join(friends_profile, by = c("player_name" = "personaname"))
  
  
  
  return(friends_stats)
})



# COMPARE FRIENDS
friends_radar <- reactive({
 
  friends_stats <- friends_stats()
  
  
  # WINS
  df_wins <- friends_stats %>% 
    filter(
      str_detect(category, 'competitive - bomb'),
      str_detect(name, 'total_wins')
    ) %>% 
    group_by(player_name) %>% 
    summarize(total_rounds_win = sum(value, na.rm = T)) %>% 
    ungroup()
  
  
  # PERFORMANCE
  df_performance <- friends_stats %>% 
    filter(
      name %in% c('total_planted_bombs', 'total_mvps', 'total_contribution_score', 'total_time_played')
    ) %>% 
    select(player_name, name, value) %>% 
    pivot_wider(
      names_from = name, 
      id_cols = player_name, 
      values_from = value
    ) %>% 
    mutate(total_time_played = total_time_played/60/60)
  
  
  # EFFICIENCY
  df_efficiency <- friends_stats %>%
    mutate(
      stat_type = case_when(
        str_detect(name, "shots") ~ "shots",
        str_detect(name, "hits") ~ "hits",
        str_detect(name, "kills") ~ "kills"
      )
    ) %>% 
    group_by(player_name, stat_type) %>% 
    summarize(total = sum(value)) %>% 
    ungroup() %>% 
    filter(!is.na(stat_type)) %>%
    group_by(player_name) %>%
    summarize(
      hits_efficiency = 100*total[stat_type == 'hits']/ total[stat_type == 'shots'],
      total_kills = sum(total[stat_type == 'kills'])
    ) %>% 
    ungroup()
  
 
  
  # Final Data
  df_final <- df_wins %>% 
    left_join(df_performance, by = 'player_name') %>% 
    left_join(df_efficiency, by = 'player_name') %>% 
    left_join(friends_stats %>% distinct(player_name, avatarfull), by = 'player_name') %>%
    mutate_at(
      vars(
        total_rounds_win, 
        total_planted_bombs,
        total_mvps, 
        total_contribution_score, 
        total_kills),
      ~(. / total_time_played)
    ) %>% # weighs by game time in hours
    select(-total_time_played) %>% 
    #tibble::column_to_rownames(var = "player_name") %>% 
    mutate_if(is.numeric, function(x){(x-min(x))/(max(x)-min(x))}) %>% # scale range 0 - 1
    mutate_if(is.numeric, round, 2)
  
  
  # loop to create the radar lists
  radr_list <- furrr::future_map(
    .x = 1:nrow(df_final),
    .f = function(x)
    {
      list(
        name = list(name = df_final$player_name[x], img = df_final$avatarfull[x]),
        data = as.numeric(df_final[x, 2:7]),
        pointPlacement = "on",
        type = "area"
      )
    }
  )

  
  # radar plot
  radar <- highchart() %>% 
    hc_chart(polar = TRUE) %>% 
    hc_add_dependency("modules/pattern-fill.js") %>%
    hc_xAxis(
      categories = c(
        "Rounds Won",
        "Planted Bombs",
        "MVPs",
        "Contribution Score",
        "Hits Efficiency",
        "Kills"
      ),
      tickmarkPlacement = "on",
      lineWidth = 0
    ) %>% 
    hc_yAxis(
      gridLineInterpolation = "polygon",
      lineWidth = 0,
      min = 0
    ) %>% 
    hc_add_series_list(
      radr_list
    ) %>%
    hc_tooltip(
      useHTML = TRUE,
      formatter = JS(
        'function () { 
          return "<b>" + this.series.name.name + "</b>"  
          + " <hr class=hr_tooltip >" 
          + "<div><img src=" + this.series.name.img+ " class=radar_img ></img></div>"
          + " <br/>"+ this.x + ": " + "<b>" + this.point.y + "</b>" 
        ;}'
      )
    )  %>% 
    hc_legend(
      labelFormat = '{name.name}',
      align = "left",
      verticalAlign = "top",
      layout = "vertical",
      x = 0,
      y = 100
    ) %>%
    hc_colors(colorRampPalette(c("#5d79ae","#0c0f12", "#ccba7c", "#413a27", "#de9b35"))(nrow(df_final)))
  
  return(radar)
}) 

comp_friends <-eventReactive(input$go, {
  
  friends_stats <- friends_stats()
  comp_friends <- column(
    width = 6,
    class = "side_side",
    h1("Compare Friends"),
    shinydashboard::box(
      width = 12,
      highchartOutput('friends_radar')  %>%
        withLoader(type = "html", loader = "loader3") 
    )
  )
  
  return(comp_friends)
})


# DREAM TEAM
dream_team <- eventReactive(input$go, {
  dream_ream <- column(
    width = 6,
    class = "side_side",
    h1("Dream Team"),
    shinydashboard::box(
      width = 12,
      h2('tt2')
    )
  )
  
  return(dream_ream)
})











# OUTPUTS
output$friends_welcome <- renderUI(friends_welcome())

output$friends_radar <- renderHighchart(friends_radar())
output$compare_friends <- renderUI(comp_friends())

output$dream_team <- renderUI(dream_team())


