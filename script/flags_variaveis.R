

source('app/functions_app/set_key.R')
source('functions/csgo_api.R')
source("packages.r")

user_id <- '76561198263364899'


stats <- csgo_api_stats(api_key,user_id)

stats <- stats %>% mutate(category = case_when(grepl("total_wins_map",name) ~ "vitorias mapa",
                                                  grepl("total_rounds_map",name) ~ "rounds mapa",
                          grepl("total_kills",name) ~ "kills com arma X"))

#total_matches_won
