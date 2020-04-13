

source('app/functions_app/set_key.R')
source('functions/csgo_api.R')
source("packages.r")

user_id <- '76561198263364899'

suporte_armas <- read_excel("data/armas csgo.xlsx",1) %>% mutate(DESC= toupper(DESC))
suporte_mapas <- read_excel("data/armas csgo.xlsx",2) %>% mutate(DESC= toupper(DESC))
suporte_stats <- read_excel("data/armas csgo.xlsx",3) %>% mutate(DESC= toupper(DESC))


stats <- csgo_api_stats(api_key,user_id)

stats$label = NA
stats$type = NA

#labels para armas
  for(i in 1:nrow(suporte_armas)){
    
    pos <- grepl(suporte_armas$ARMA[i],stats$name)
    
    stats$label[pos] <- suporte_armas$DESC[i]
    stats$type[pos] <- "weapon info"
  }


#labels para mapas
  for(i in 1:nrow(suporte_mapas)){
    
    pos <- grepl(suporte_mapas$MAPA[i],stats$name)
    
    stats$label[pos] <- suporte_mapas$DESC[i]
    stats$type[pos] <- suporte_mapas$CATEGORIA[i]
  }

#labels para stats geral
  for(i in 1:nrow(suporte_stats)){
    
    pos <- which(suporte_stats$STAT[i]==stats$name)
    
    stats$label[pos] <- suporte_stats$DESC[i]
    stats$type[pos] <- suporte_stats$CATEGORIA[i]
  }
