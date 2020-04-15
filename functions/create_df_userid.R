

source('app/functions_app/set_key.R')
source('functions/csgo_api.R')
source("packages.r")

#user_name vira do shiny app quando o usuario digitar


create_df_stats_user <- function(api_key,user_name){
  
  suporte_armas <- read_rds("data/armas.rds") %>% mutate(DESC= toupper(DESC))
  suporte_mapas <- read_rds("data/mapas.rds") %>% mutate(DESC= toupper(DESC))
  suporte_stats <- read_rds("data/stats.rds") %>% mutate(DESC= toupper(DESC))
  
  user_id <- as.character(csgo_api_profile_by_name(api_key,user_name))
  
  stats <- csgo_api_stats(api_key,user_id)
  
  #profile_name <- csgo_api_profile(api_key,user_id) #$personaname
  
  stats2 <- stats
  
  stats2$label = NA
  stats2$type = NA
  
  #labels para armas
  for(i in 1:nrow(suporte_armas)){
    
    pos <- grepl(suporte_armas$ARMA[i],stats2$name)
    
    stats2$label[pos] <- suporte_armas$DESC[i]
    stats2$type[pos] <- "weapon info"
  }
  
  
  #labels para mapas
  for(i in 1:nrow(suporte_mapas)){
    
    pos <- grepl(suporte_mapas$MAPA[i],stats2$name)
    
    stats2$label[pos] <- suporte_mapas$DESC[i]
    stats2$type[pos] <- suporte_mapas$CATEGORIA[i]
  }
  
  #labels para stats geral
  for(i in 1:nrow(suporte_stats)){
    
    pos <- which(suporte_stats$STAT[i]==stats2$name)
    
    stats2$label[pos] <- suporte_stats$DESC[i]
    stats2$type[pos] <- suporte_stats$CATEGORIA[i]
  }
  
  stats2 <- stats2 %>% filter(!is.na(label)) %>% mutate(player_name = user_name)
  
    lista_db <- list(db_raw=stats,db_clean=stats2,player=user_name)
  
}

