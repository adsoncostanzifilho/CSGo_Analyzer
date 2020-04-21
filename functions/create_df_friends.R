

source('app/functions_app/set_key.R')
source('functions/csgo_api.R')
source('functions/create_df_userid.R')
source("packages.r")

create_df_stats_friends <- function(api_key,user_name){

user_id <- as.character(csgo_api_profile_by_name(api_key,user_name)) ##user_name vira do shiny app quando o usuario digitar

friend_list <- csgo_api_friend(api_key,user_id)

#friends_permission_list <- list()


  for(i in 1:nrow(friend_list)){
    
    temp <- csgo_api_profile(api_key,friend_list$steamid[i])
    
    if(("commentpermission" %in% colnames(temp))){
        
        friend_list$public[i] <- ifelse(temp$commentpermission == 1,"Public","Not Public")
    }
    else{
      
      friend_list$public[i] <- "Not Public"
      
    }
  }
    


friend_list <- friend_list %>% filter(public == "Public")


friend_data_list <- list()


  if(nrow(friend_list) >0){

    for(i in 1:nrow(friend_list)){
      
      user = as.character(friend_list$steamid[i])
      
      friend_data_list[[i]] <- create_df_stats_user(api_key,user)
      
    }
    
    return(list(friend_data_list,"Database was created!"))
  }
  else{
    
    return(list(friend_data_list,"There is no public data for friends of this steam user"))
    
  }


}