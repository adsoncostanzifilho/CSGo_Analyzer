

source('app/functions_app/set_key.R')
source('functions/csgo_api.R')
source('functions/create_df_userid.R')
source("packages.r")

create_df_stats_friends <- function(api_key,user_key){

  if(is.na(as.numeric(user_key))){
    
    user_id <- as.character(as.vector(csgo_api_profile_by_name(api_key,user_key))) 
    
  }else{
    user_id <- as.character(user_key)
  }
  

friend_list <- csgo_api_friend(api_key,user_id)

#friends_permission_list <- list()


  for(i in 1:nrow(friend_list)){
    
    temp <- csgo_api_profile(api_key,friend_list$steamid[i])
    
    if(("communityvisibilitystate" %in% colnames(temp))){
        
        friend_list$public[i] <- ifelse(as.numeric(temp$communityvisibilitystate)  > 1,"Public","Not Public")
        friend_list$name[i] <- temp$personaname
    }
    else{
      
      friend_list$public[i] <- "Not Public"
      friend_list$name[i] <- temp$personaname
      
    }
    print(paste("selecionando amigos publicos",i,sep = " - "))
  }
    


friend_list <- friend_list %>% filter(public == "Public")


friend_data_list <- list()


  if(nrow(friend_list) >0){

    for(i in 1:nrow(friend_list)){
      
      user = as.character(friend_list$steamid[i])
      
      friend_data_list[[i]] <- create_df_stats_user(api_key,user)
      
      print(paste("selecionando dados de amigos",i,sep = " - "))
      
    }
    
    return(list(friend_data_list,"Database was created!"))
  }
  else{
    
    return(list(friend_data_list,"There is no public data for friends of this steam user"))
    
  }


}
