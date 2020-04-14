# COLLECT CS GO DATA TROUGHT STEAM API #

#-- create a steam account to have API key
# https://steamcommunity.com/login/home/?goto=%2Fdev%2Fapikey

#-- steam API documentation
# https://developer.valvesoftware.com/wiki/Steam_Web_API

# INPUTS ----
# key ('string'): key of the steam API
# user_id ('string'): the steamid, the steam user ID

# OUTPUTS ----
# data frame

# EXAMPLE ----
# source('functions/csgo_api.R')
# 
# db_ach <- csgo_api_ach(key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', user_id = '76561198263364899')
# db_stats <- csgo_api_stats(key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', user_id = '76561198263364899')
# db_friend <- csgo_api_friend(key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', user_id = '76561198263364899')
# db_profile <- csgo_api_profile(key = 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX', user_id = '76561198263364899')
 

require(httr)
require(jsonlite)
csgo_api_ach <- function(key, user_id)
{
  
  # Achievements
  call_cs_ach <- sprintf(
    'http://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/?appid=730&key=%s&steamid=%s',
    key,
    user_id
  )
  
  api_query_ach <- GET(call_cs_ach)
  
  api_content_ach <- content(api_query_ach, 'text')
  
  json_content_ach <- fromJSON(api_content_ach, flatten = TRUE)
  
  db_achievements <- as.data.frame(json_content_ach$playerstats$achievements)
  
  # RETURN
  return(db_achievements)
  
}


csgo_api_stats <- function(key, user_id)
{
  # Stats
  call_cs_stats <- sprintf(
    'http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002/?appid=730&key=%s&steamid=%s&apiname=%s',
    key,
    user_id,
    '1458786300'
  )
  
  api_query_stats <- GET(call_cs_stats)
  
  api_content_stats <- content(api_query_stats, 'text')
  
  json_content_stats <- fromJSON(api_content_stats, flatten = TRUE)
  
  db_stats <- as.data.frame(json_content_stats$playerstats$stats)
  
  # RETURN
  return(db_stats)
}


csgo_api_friend <- function(key, user_id)
{
  # Friends
  call_cs_friend <- sprintf(
    'http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?appid=730&relationship=friend&key=%s&steamid=%s',
    key,
    user_id
  )
  
  api_query_friend <- GET(call_cs_friend)
  
  api_content_friend <- content(api_query_friend, 'text')
  
  json_content_friend <- fromJSON(api_content_friend, flatten = TRUE)
  
  db_friend <- as.data.frame(json_content_friend$friendslist$friends)
  
  # RETURN
  return(db_friend)
  
}
   

csgo_api_profile <- function(key, user_id)
{
  # Profile
  call_cs_profile <- sprintf(
    'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?&key=%s&steamids=%s',
    key,
    user_id
  )
  
  api_query_profile <- GET(call_cs_profile)
  
  api_content_profile <- content(api_query_profile, 'text')
  
  json_content_profile <- fromJSON(api_content_profile, flatten = TRUE)
  
  db_profile <- as.data.frame(json_content_profile$response$players)
  
  
  # RETURN
  return(db_profile)
  
} 


csgo_api_profile_by_name <- function(key, username)
{
  # Profile by user name
  call_cs_profile <- sprintf(
    'http://api.steampowered.com/ISteamUser/ResolveVanityURL/v0001/?&key=%s&vanityurl=%s',
    key,
    username
  )
  
  api_query_profile <- GET(call_cs_profile)
  
  api_content_profile <- content(api_query_profile, 'text')
  
  json_content_profile <- fromJSON(api_content_profile, flatten = TRUE)
  
  db_profile <- as.data.frame(json_content_profile$response)
  
  # RETURN
  if(db_profile$success != 1) 
  {
    return("User not found")
  } 
  
  if(db_profile$success == 1) 
  {
    return(db_profile$steamid)
  }
  
}




