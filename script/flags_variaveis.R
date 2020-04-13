

source('app/functions_app/set_key.R')
source('functions/csgo_api.R')
source("packages.r")

user_id <- '76561198005310929'


stats <- csgo_api_stats(api_key,user_id)

stats <- stats %>% mutate(category = case_when(grepl("total_wins_map",name) ~ "rounds vencidos mapa",
                          grepl("total_rounds_map",name) ~ "rounds mapa",
                          grepl("total_kills",name) ~ "kills com arma X",
                          grepl("total_planted_bombs",name) ~ "C4 plantadas",
                          grepl("total_defused_bombs",name) ~ "C4 desarmadas",
                          grepl("total_wins_pistolround",name) ~ "vitorias em pistol round",
                          grepl("total_weapons_donated",name) ~ "armas doadas",
                          grepl("total_weapons_donated",name) ~ "armas doadas",
                          grepl("total_shots_",name) ~ "tiros disparados",
                          grepl("total_hits_",name) ~ "tiros certos",
                          name== "total_shots_hit" ~ "tiros certos total",
                          name=="total_matches_won" ~ "total de vitorias",
                          name=="total_mvps" ~ "total MVPS",
                          grepl("total_matches_won_",name) ~ "total de vitorias no mapa",
                          name== "total_matches_played","total de partidas jogadas",
                          name=="total_deaths" ~ "total de mortes",
                          name=="total_damage_done" ~ "total de dano causado",
                          name=="	total_progressive_matches_won" ~ "total de vitorias consecutivas"
                          
                          
            
                          	
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          
                          ))



friends <- csgo_api_friend(api_key,user_id)

#total_matches_won
