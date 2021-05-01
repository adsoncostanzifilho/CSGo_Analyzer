#-- FRIENDS SERVER --#
# aux function for create the skull scale in the dream team table #
rating_skull <- function(rating, max_rating = 10) {
  star_icon <- function(empty = FALSE) {
    tagAppendAttributes(
      shiny::icon("skull"),
      style = paste("color:", if (empty) "#edf0f2" else "#ce8404"),
      "aria-hidden" = "true"
    )
  }
  rounded_rating <- floor(rating + 0.5)  # always round up
  stars <- lapply(seq_len(max_rating), function(i) {
    if (i <= rounded_rating) star_icon() else star_icon(empty = TRUE)
  })
  label <- sprintf("%s out of %s skulls", rating, max_rating)
  div(title = label, role = "img", stars)
}


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
  friends <- get_stats_friends(api_key = api_key, user_id = input$user_id, n_return = 30)
  
  # Bind Individual rows to the friends data
  friends_profile <- friends$friends %>%
    bind_rows(user_profile %>% select(steamid, personaname, profileurl, avatarfull))
  
  # Join profile variables
  friends_stats <- friends$friends_stats %>%
    bind_rows(user_stats) %>%
    left_join(friends_profile, by = c("player_name" = "personaname"))
  
  return(friends_stats)
})

# FRIENDS STATS METRICS
friends_stats_metric <- eventReactive(input$go, {
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
    left_join(friends_stats %>% distinct(player_name, avatarfull, profileurl), by = 'player_name') %>%
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
  
  return(df_final)
  
})





# COMPARE FRIENDS
friends_radar <- reactive({
 
  df_final <- friends_stats_metric()
  teste <<- df_final
  
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
  
  comp_friends <- column(
    width = 6,
    class = "side_side",
    h1("Compare Friends"),
    shinydashboard::box(
      width = 12,
      highchartOutput('friends_radar')  %>%
        withSpinner(type = 7, color = "#ce8404", id = "my_loader") 
    )
  )
  
  return(comp_friends)
})



# DREAM TEAM
dream_team_table <- reactive({
  
  db_profile <- user_profile()
  friends_stats_metric <- friends_stats_metric()
  
  friends_stats_metric <- friends_stats_metric %>%
    mutate(
      best_player_score = round(
        (total_rounds_win 
         + total_planted_bombs 
         + total_mvps 
         + total_contribution_score 
         + hits_efficiency 
         + total_kills)/6*10, 2)
    )
  
  player <- friends_stats_metric %>%
    # filter(player_name == 'Mlk da Escopeta')
    filter(player_name == db_profile$personaname)
  
  sel_friends <- friends_stats_metric %>%
    # filter(player_name != 'Mlk da Escopeta') %>%
    filter(player_name != db_profile$personaname) %>%
    top_n(n = 4, wt = best_player_score) %>%
    bind_rows(player) %>% 
    arrange(desc(best_player_score)) %>%
    select(avatarfull, player_name, best_player_score, profileurl) %>%
    mutate(
      #avatarfull = paste0("<div><a href =",profileurl, ">","< img src = '",avatarfull, "' class = 'table_img'> </a> </div>")
      avatarfull = paste0('<img src = ',avatarfull, " class = 'table_img'> ")
    ) %>%
    rename(
      "Player Avatar" = "avatarfull",
      "Player Name" = "player_name",
      "Score" ="best_player_score"
    )
    
  tab_return <- reactable(
    sel_friends,
    columns = list(
      profileurl = colDef(show = FALSE),
      `Player Avatar` = colDef(
        sortable = FALSE,
        html = TRUE,
        align = "center",
      ),
      `Player Name` = colDef(
        # maxWidth = 200
      ),
      Score = colDef(
        cell = function(Score) rating_skull(Score))
    )
  )
  
  return(tab_return)
})

dream_team <- eventReactive(input$go, {
  
  dream_ream <- column(
    width = 6,
    class = "side_side",
    h1("Dream Team"),
    shinydashboard::box(
      width = 12,
      reactableOutput("dream_team_tab") %>%
        withSpinner(type = 7, color = "#ce8404", id = "my_loader") 
    )
  )
  
  return(dream_ream)
})



# WHOLE PAGE 
whole_page_friends <- eventReactive(input$go, {
  
  friends_stats <- friends_stats()
  
  whole_pg <- fluidRow(
    
    uiOutput('friends_welcome'),
    
    column(
      width = 12,
      class = 'home_welcome',
      
      uiOutput('compare_friends'), 
      
      uiOutput('dream_team')
    )
  )
  
  return(whole_pg)
})







# OUTPUTS
output$friends_welcome <- renderUI(friends_welcome())

output$friends_radar <- renderHighchart(friends_radar())
output$compare_friends <- renderUI(comp_friends())

output$dream_team_tab <- renderReactable(dream_team_table())
output$dream_team <- renderUI(dream_team())

output$whole_page_friends <- renderUI(whole_page_friends())
