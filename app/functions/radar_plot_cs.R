get_stats_friends2 <- function(api_key, user_id) #usar a get_stats_friends quando estiver atualizada no CRAN - add possibly
{
  
  # COLLECT THE PROFILE BY USER NAME OR BY USER ID
  # it will depend on the type of user_id
  if(is.na(as.numeric(user_id)))
  {
    user_profile <- csgo_api_profile(api_key, user_id, name = TRUE)
    user_id <- as.character(as.vector(user_profile$steamid))
  }else{
    user_id <- as.character(user_id)
  }
  
  # GETING THE FRIENDS IDs
  friend_list <- csgo_api_friend(api_key, user_id)
  
  # VERIFY IF THE USER IS PUBLIC OR NOT
  print("Public friends check..")
  
  # auxiliary function to create/check if the friend has public data or not
  check_public <- function(steamid, ...)
  {
    df_return <- data.frame(
      steamid = steamid,
      personaname = NA,
      public = NA,
      profileurl = NA,
      avatarfull = NA
    )
    
    temp <- csgo_api_profile(api_key, steamid)
    
    if(("communityvisibilitystate" %in% colnames(temp)))
    {
      df_return$public <- ifelse(
        as.numeric(temp$communityvisibilitystate) > 1,
        "Public",
        "Not Public"
      )
      df_return$personaname <- temp$personaname
      df_return$profileurl <- temp$profileurl
      df_return$avatarfull <- temp$avatarfull
      
    }
    else{
      df_return$public <- "Not Public"
    }
    return(df_return)
  }
  
  friend_list <- purrr::map_df(.x = friend_list$steamid, .f = check_public)
  
  friend_list2 <- friend_list %>%
    dplyr::filter(public == "Public")
  
  # GETING THE STATS OF EACH FRIEND
  print("Pulling friends stats..")
  return_list <- list()
  
  if(nrow(friend_list2) > 0)
  {
    db_friends_complete <- purrr::map2_df(
      .x = api_key,
      .y = as.character(friend_list2$steamid),
      .f = purrr::possibly(get_stats_user,"Cant retrieve data")
    )
    
    db_friends_complete <- db_friends_complete %>%
      dplyr::filter(!is.na(value))
    
    return_list$friends_stats <- db_friends_complete
    return_list$friends <- friend_list
  }else{
    return_list$friends_stats <- 'NO PUBLIC FRIENDS'
    return_list$friends <- friend_list
  }
  
  return(return_list)
  
}

require(CSGo)
require(tibble)
require(dplyr)
require(stringr)
require(tidyr)
require(plotly)

user_id = '76561198263364899'
api_key = 'B8A56746036078F2D655CB3F1073F7DF'

radar_shiny <- function(user_id = '76561198263364899', api_key = 'B8A56746036078F2D655CB3F1073F7DF'){
  
  
  ### get friend list
  friend_list <- csgo_api_friend(api_key, user_id)
  
  ### get friend names
  #names_friend <- purrr::map2(api_key, friend_list$steamid, csgo_api_profile) %>%
  # bind_rows() %>% 
  #select(steamid, personaname, profileurl)
  
  ### get all players stats
  stats_friends <- get_stats_friends2(api_key, user_id) #trocar nome funcao pela original corrigida - add possibly
  
  user_stats <- get_stats_user(api_key, user_id)
  
  data_friends <- stats_friends$friends_stats %>% 
    bind_rows(user_stats)
  
  #----------------------------------------------------#
  
  df_wins <- data_friends %>% 
    filter(
      str_detect(category, 'competitive - bomb'),
      str_detect(name, 'total_wins')
      
    ) %>% 
    group_by(player_name) %>% 
    summarize(total_rounds_win = sum(value, na.rm = T)) %>% 
    ungroup()
  
  #----------------------------------------------------#
  
  df_performance <- data_friends %>% 
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
  
  #----------------------------------------------------#
  
  df_efficiency <- data_friends %>%
    filter(
      name_match %in% c("ak47", "aug", "awp", "fiveseven",
                        "hkp2000", "m4a1", "mp7", "p90",
                        "sg556", "xm1014")
    ) %>%
    mutate(
      stat_type = case_when(
        str_detect(name, "shots") ~ "shots",
        str_detect(name, "hits") ~ "hits",
        str_detect(name, "kills") ~ "kills"
      )
    ) %>% 
    group_by(player_name, stat_type) %>% 
    summarize(
      total = sum(value)
    ) %>% 
    ungroup() %>% 
    group_by(player_name) %>%
    summarize(
      hits_efficiency = 100*total[stat_type == 'hits']/ total[stat_type == 'shots'],
      total_kills = sum(total[stat_type == 'kills'])
    ) %>% 
    ungroup()
  
  #----------------------------------------------------#
  
  nomes <- unique(df_wins$player_name)
  
  df_final <- df_wins %>% 
    left_join(df_performance, by = 'player_name') %>% 
    left_join(df_efficiency, by = 'player_name') %>% 
    mutate_at(vars(total_rounds_win, total_planted_bombs,
                   total_mvps, total_contribution_score, total_kills), ~(. / total_time_played)) %>% #pondera pelo tempo de jopgo em horas
    select(-total_time_played) %>% 
    tibble::column_to_rownames(var = "player_name") %>% 
    mutate_all(function(x){(x-min(x))/(max(x)-min(x))}) #scale para range 0 - 1
  
  rownames(df_final) <- nomes
  
  
  fig <- plot_ly(
    type = 'scatterpolar',
    fill = 'toself'
  ) 
  
  for(i in 1:nrow(df_final)){
    
    #transforma cada linha do df num vetor
    temp <- c(df_final[i,]) %>% unlist() %>% as.vector()
    
    fig <- fig %>% 
      add_trace(
        r = temp,
        theta = colnames(df_final),
        name = rownames(df_final)[i]
      ) 
    
  }
  
  fig
  
}