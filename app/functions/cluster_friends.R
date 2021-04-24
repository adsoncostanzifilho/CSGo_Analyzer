require(CSGo)
require(tibble)
require(dplyr)
require(stringr)
require(tidyr)
require(janitor)
require(factoextra)
#require(cluster)
require(psych)

user_id = '76561198263364899'
api_key = 'B8A56746036078F2D655CB3F1073F7DF'
  
cluster_players <- function(api_key = 'B8A56746036078F2D655CB3F1073F7DF' , user_id = '76561198263364899'){
    
    
    ### get friend list
    friend_list <- csgo_api_friend(api_key, user_id)
    
    ### get friend names
    #names_friend <- purrr::map2(api_key, friend_list$steamid, csgo_api_profile) %>%
    # bind_rows() %>% 
    #select(steamid, personaname, profileurl)
    
    ### get all players stats
    stats_friends <- get_stats_friends(api_key, user_id) #trocar nome funcao pela original corrigida - add possibly
    
    user_stats <- get_stats_user(api_key, user_id)
    
    data_friends <- stats_friends$friends_stats %>% 
      bind_rows(user_stats)
    
    data_to_clust <- data_friends %>% 
      select(name, value, player_name) %>% 
      unique() %>% 
      pivot_wider(
        names_from = name, 
        id_cols = player_name, 
        values_from = value
      ) %>%
      column_to_rownames('player_name') %>% 
      janitor::remove_constant() %>% 
      mutate_all(~(replace_na(.,0))) #input zero if non information
    
    
    std_df <- scale(data_to_clust) %>% 
      data.frame() %>% 
      mutate_all(~(replace_na(.,0))) %>% 
      janitor::remove_constant()
    
    #------------------------------------------------------------------------------#
    #------------------------------------------------------------------------------#
    #------------------------------------------------------------------------------#
    
    fit <- prcomp(std_df)
    
    n_comp <- get_eigenvalue(fit) %>% 
      filter(cumulative.variance.percent < 81) %>%  #componentes tais que contemplam 80% da var
      nrow()
    
    #fviz_eig(fit, addlabels=TRUE, ylim = c(0,50))
    
    # componentes_pca <- fit$x %>% 
    #   data.frame() %>% 
    #   select(1:all_of(n_comp))
    
    
    # principal 
    pca_rot <- principal(std_df, nfactors=n_comp,
                        n.obs=nrow(std_df), rotate="varimax", scores=TRUE)
    
    lista <- factor.scores(std_df,pca_rot, 
                           Phi = NULL, 
                           method = c("Thurstone", "tenBerge", "Anderson",
                                      "Bartlett", "Harman","components"),
                           rho=NULL)
    
    lista2 <- lista$scores %>% 
      data.frame() 
    
    
    #------------------------------------------------------------------------------#
    #------------------------------------------------------------------------------#
    #------------------------------------------------------------------------------#
    
    distance <- get_dist(lista2)
    fviz_dist(distance, gradient = list(low = "#00AFBB", mid = "white", high = "#FC4E07"))
    
    sill <- factoextra::fviz_nbclust(lista2, kmeans, method = "silhouette")
    
    num_centroids <- which(sill[["data"]]$y == max(sill[["data"]]$y))
    
    # compute gap statistic
    # set.seed(123)
    # gap_stat <- clusGap(lista2, FUN = kmeans, nstart = 25,
    #                     K.max = 5, B = 200)
    # 
    # fviz_gap_stat(gap_stat)
    
    kmeans_cluster <- kmeans(lista2, centers = num_centroids, nstart = 25)
    
    plot_clust <- fviz_cluster(kmeans_cluster, data = lista2) +
      ylab("") + 
      xlab("") + 
      theme_bw()
    
    return(plot_clust)
    
}
  
  
  