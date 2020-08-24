
source('app/functions_app/set_key.R')
source('functions/csgo_api.R')
source('functions/create_df_userid.R')
source('functions/create_df_friends.R')
source("packages.r")


ss <- create_df_stats_user(api_key,"76561198873223629")[[2]]

friend_list <- csgo_api_friend(api_key,user_id)
