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
  label <- sprintf("%s out of %s", rating, max_rating)
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
  friends <- get_stats_friends(api_key = api_key, user_id = input$user_id, n_return = 15)
  
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

comp_friends <- eventReactive(input$go, {
  
  comp_friends <- column(
    width = 6,
    class = "side_side",
    h1("Compare Friends"),
    shinydashboard::box(
      width = 12,
      class = "box_radar",
      highchartOutput('friends_radar')  %>%
        shinycssloaders::withSpinner(type = 7, color = "#ce8404", id = "my_loader")
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
    filter(player_name == db_profile$personaname)
  
  sel_friends <- friends_stats_metric %>%
    filter(player_name != db_profile$personaname) %>%
    top_n(n = 4, wt = best_player_score) %>%
    bind_rows(player) %>% 
    arrange(desc(best_player_score)) %>%
    select(avatarfull, player_name, best_player_score, profileurl)
    
  
  tab_return <- reactable(
    sel_friends,
    rowClass = function(index) {
      if(sel_friends$player_name[index] == db_profile$personaname){
        "player_tab_high"
      }
    },
    
    columns = list(
      profileurl = colDef(show = FALSE),
      
      avatarfull = colDef(
        name = "Player Avatar",
        align = "center",
        sortable = FALSE,
        cell = function(value, index) {
          htmltools::tags$a(
            href = sel_friends$profileurl[index],
            target = "_blank",
            htmltools::tags$img(src = value, class = 'table_img')
          )
        }),
      
      player_name = colDef(
        name = "Player Name"
      ),
      best_player_score = colDef(
        name = "Score",
        cell = function(best_player_score) rating_skull(best_player_score)
      )
    )
  )
  
  return(tab_return)
})

all_friends_table <-reactive({
  
  db_profile <- user_profile()
  friends_stats_metric <- friends_stats_metric()
  
  friends_tab <- friends_stats_metric %>%
    mutate(
      best_player_score = round(
        (total_rounds_win 
         + total_planted_bombs 
         + total_mvps 
         + total_contribution_score 
         + hits_efficiency 
         + total_kills)/6*10, 2)
    ) %>%
    arrange(desc(best_player_score)) %>%
    select(avatarfull, player_name, best_player_score, profileurl)
    
    
  tab_return <- reactable(
    friends_tab,
    filterable = TRUE,
    defaultPageSize = 5,
    rowClass = function(index) {
      if (friends_tab$player_name[index] == db_profile$personaname) {
        "player_tab_high"
      }
    },
    
    columns = list(
      profileurl = colDef(show = FALSE),
      
      avatarfull = colDef(
        name = "Player Avatar",
        align = "center",
        sortable = FALSE,
        filterable = FALSE,
        cell = function(value, index) {
        htmltools::tags$a(
          href = friends_tab$profileurl[index],
          target = "_blank",
          htmltools::tags$img(src = value, class = 'table_img_all')
        )
      }),
      
      player_name = colDef(
        name = "Player Name",
        filterable = TRUE
      ),
      best_player_score = colDef(
        name = "Score",
        cell = function(best_player_score) rating_skull(best_player_score),
        filterable = TRUE
      )
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
      class = "box_radar",
      tabsetPanel(
        tabPanel(
          title = "Dream Team",
          reactableOutput("dream_team_tab") %>%
            shinycssloaders::withSpinner(type = 7, color = "#ce8404", id = "my_loader")
        ),
        tabPanel(
          title = "Search Friends",
          reactableOutput("all_friends_tab") %>%
            shinycssloaders::withSpinner(type = 7, color = "#ce8404", id = "my_loader")
        )
      )
    )
    
  )
  
  return(dream_ream)
})



# CLUSTER
friends_cluster <- eventReactive(input$go,{
  
  friends_stats <- friends_stats() %>%
    arrange(player_name, name, value)
    

  data_to_clust <- friends_stats %>% 
    select(name, value, player_name) %>% 
    unique() %>% 
    pivot_wider(
      names_from = name, 
      id_cols = player_name, 
      values_from = value
    ) %>%
    textshape::column_to_rownames('player_name') %>%
    janitor::remove_constant() %>% 
    mutate_all(~(replace_na(.,0))) #input zero if non information
  
  # scaling the var
  std_df <- data_to_clust %>%
    mutate_if(is.numeric, scale) %>%
    mutate_all(~(replace_na(.,0))) %>% 
    janitor::remove_constant()
  
  # components
  fit <- prcomp(std_df)
  
  n_comp <- factoextra::get_eigenvalue(fit) %>% 
    filter(cumulative.variance.percent < 81) %>%  # components to have at least  80% 
    nrow()
  
  # principal componentes
  pca_rot <- principal(
    std_df,
    nfactors = n_comp,
    n.obs = nrow(std_df), 
    rotate = "varimax",
    scores = TRUE
  )
  
  list_score <- factor.scores(
    std_df,
    pca_rot, 
    Phi = NULL, 
    method = c(
      "Thurstone",
      "tenBerge",
      "Anderson",
      "Bartlett",
      "Harman",
      "components"
    ),
    rho = NULL)
    
  list_score2 <- list_score$scores %>% 
    data.frame() 
  
  # distances
  distance <- factoextra::get_dist(list_score2)
  
  sill <- factoextra::fviz_nbclust(list_score2, kmeans, method = "silhouette", k.max = nrow(list_score2)-1)
  
  num_centroids <- which(sill[["data"]]$y == max(sill[["data"]]$y))
  
  # Kmeans
  kmeans_cluster <- kmeans(list_score2, centers = num_centroids, nstart = 25)
  
  plot_clust <- fviz_cluster(kmeans_cluster, data = list_score2)
  
  # data frame to plot
  plot_df <- plot_clust$data %>%
    left_join(friends_stats %>% distinct(player_name, avatarfull), by = c("name"="player_name"))
  
  
  # cluster series to plot de polygons
  ds <- purrr::map(
    .x = levels(plot_df$cluster),
    .f = function(index){
      temp <- plot_df %>%
        filter(cluster == index)
      dt <- cbind(temp$x, temp$y)
      dt <- igraph::convex_hull(dt)
      dt <- list_parse2(as.data.frame(dt$rescoords))
      list(
        data = dt, 
        #name = paste("Cluster", x),
        type = "polygon",
        id = index,
        showInLegend = F,
        opacity = 0.5,
        enableMouseTracking = F
      )
    })
  
  
    
  cluster_plot <- plot_df %>%
    hchart(
      type = "scatter", 
      hcaes(
        x = x, 
        y = y, 
        group = cluster)) %>%
    hc_add_series_list(ds) %>%
    hc_tooltip(
      useHTML = TRUE,
      formatter = JS(
        'function () { 
          return "Player: " + "<b>" + this.point.name + "</b>"  
          + " <hr class=hr_tooltip >" 
          + "<div><img src=" + this.point.avatarfull + " class=radar_img ></img></div>"
          + " <br/> Cluster: " + "<b>" + this.point.cluster + "</b>" 
        ;}'
      )
    ) %>%
    hc_xAxis(title = list(text = "Dim 1")) %>%
    hc_yAxis(
      title = list(text = "Dim 2"),
      tickLength = 0,
      gridLineColor = 'transparent'
    ) %>%
    hc_colors(
      colorRampPalette(
        c("#5d79ae","#0c0f12", "#ccba7c", "#413a27", "#de9b35"))
      (length(levels(plot_clust$data$cluster))))
  
  return(cluster_plot)
  
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
    ),
    
    br(),
    column(
      width = 12,
      class = 'cluster_col',
      
      h1("Friends' Groups", class = "h1_center"),
      shinydashboard::box(
        width = 10,
        highchartOutput('cluster_plot')  %>%
          shinycssloaders::withSpinner(type = 7, color = "#ce8404", id = "my_loader") 
      )
    )
    
  )
  
  return(whole_pg)
})







# OUTPUTS
output$friends_welcome <- renderUI(friends_welcome())

output$friends_radar <- renderHighchart(friends_radar())
output$compare_friends <- renderUI(comp_friends())

output$dream_team_tab <- renderReactable(dream_team_table())
output$all_friends_tab <- renderReactable(all_friends_table())
output$dream_team <- renderUI(dream_team())

output$cluster_plot <- renderHighchart(friends_cluster())

output$whole_page_friends <- renderUI(whole_page_friends())
