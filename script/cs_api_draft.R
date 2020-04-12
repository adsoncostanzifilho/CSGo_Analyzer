# COLLECT CS GO DATA TROUGHT STEAM API #

#-- create a steam account to have API key
# https://steamcommunity.com/login/home/?goto=%2Fdev%2Fapikey

#-- steam API documentation
# https://developer.valvesoftware.com/wiki/Steam_Web_API

require(httr)
require(jsonlite)
key <- 'xxxx'
user_id <- '76561198263364899'

# Achievements
call_cs_ach <- paste0('http://api.steampowered.com/ISteamUserStats/GetPlayerAchievements/v0001/?appid=730',
                      '&key=', key,
                      '&steamid=', user_id)

api_query_ach <- GET(call_cs_ach)

api_content_ach <- content(api_query_ach, 'text')

json_content_ach <- fromJSON(api_content_ach, flatten = TRUE)

db_achievements <- as.data.frame(json_content_ach$playerstats$achievements)

# Stats
api_name <- '1458786300'

call_cs_stats <- paste0('http://api.steampowered.com/ISteamUserStats/GetUserStatsForGame/v0002/?appid=730',
                      '&key=', key,
                      '&steamid=', user_id,
                      '&apiname=', api_name)

api_query_stats <- GET(call_cs_stats)

api_content_stats <- content(api_query_stats, 'text')

json_content_stats <- fromJSON(api_content_stats, flatten = TRUE)

db_stats <- as.data.frame(json_content_stats$playerstats$stats)


# Friends
call_cs_friend <- paste0('http://api.steampowered.com/ISteamUser/GetFriendList/v0001/?appid=730',
                        '&key=', key,
                        '&steamid=', user_id,
                        '&relationship=friend')

api_query_friend <- GET(call_cs_friend)

api_content_friend <- content(api_query_friend, 'text')

json_content_friend <- fromJSON(api_content_friend, flatten = TRUE)

db_friend <- as.data.frame(json_content_friend$friendslist$friends)


# Profile
call_cs_profile <- paste0('http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?',
                         '&key=', key,
                         '&steamids=', user_id)

api_query_profile <- GET(call_cs_profile)

api_content_profile <- content(api_query_profile, 'text')

json_content_profile <- fromJSON(api_content_profile, flatten = TRUE)

db_profile <- as.data.frame(json_content_profile$response$players)







