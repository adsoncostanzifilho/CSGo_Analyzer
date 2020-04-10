

##### Analises descritivas #####

source("packages.r")


db <- readRDS("data/Csgo_data.rds")


#### Graf 1 ####

db %>%
  group_by(PARTIDA) %>%
  summarize(RESULTADO = unique(RESULTADO)) %>%
  group_by(RESULTADO) %>% 
  summarize(count= n()) %>% 
  plot_ly(labels = ~RESULTADO, values = ~count,marker = list(colors = c('red', 'green','yellow'))) %>%
  add_pie(hole = 0.6) %>%
  layout(title = "",  showlegend = T,
         xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
         annotations=list(text=paste("Partidas = ",length(unique(db$PARTIDA))), "showarrow"=F,
                          font=list(size = 30, color= "black")))

#### Graf 2 ####

db %>% select(PARTIDA,ROUNDS_WIN,MAPA,DURAÇÃO_MIN,RESULTADO) %>% unique() %>% 
  group_by(MAPA) %>% 
  dplyr::summarize(duracao_media = mean(DURAÇÃO_MIN,na.rm = T),
                   rounds_media = median(ROUNDS_WIN,na.rm = T),
                   n = n(),
                   tx_win = 100*(sum(RESULTADO == "Vitória",na.rm=T) / n)) %>% 
  plot_ly(labels = ~MAPA, values = ~n, type = 'pie',
          textposition = 'inside',
          textinfo = 'label+percent') %>% 
  layout(title = 'Frequência de Mapas',
        xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
        yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE))


#### Graf 3 ####

db %>% select(PARTIDA,ROUNDS_WIN,MAPA,DURAÇÃO_MIN,RESULTADO) %>% unique() %>% 
  group_by(MAPA) %>% 
  dplyr::summarize(duracao_media = mean(DURAÇÃO_MIN,na.rm = T),
                   rounds_media = median(ROUNDS_WIN,na.rm = T),
                   n = n(),
                   tx_win = 100*(sum(RESULTADO == "Vitória",na.rm=T) / n)) %>% 
  plot_ly(
    x = ~MAPA,
    y = ~rounds_media,
    type = "bar",
    text=~n,
    name="Media de rounds vencidos",
    marker = list(color = "orange")
  ) %>% add_trace(x = ~MAPA,
                  y = ~tx_win,
                  type = 'scatter', 
                  mode = 'lines',
                  line = list(color = "black"),
                  marker = list(color = "black"),
                  yaxis = "y2",
                  name = paste0("Tx. Vitória"))%>% 
  layout(title =paste0('Tx. de Vitória', ' e Rounds Win'), showlegend = T,yaxis=list(title="Rounds"),
         xaxis=list(title="MAPA"),yaxis2 = list(overlaying = "y", side = "right",title="%"))



#### Graf 4 ####

db %>% select(PARTIDA,ROUNDS_WIN,MAPA,DURAÇÃO_MIN,RESULTADO) %>% unique() %>% 
  group_by(MAPA) %>% 
  dplyr::summarize(duracao_media = round(mean(DURAÇÃO_MIN,na.rm = T),2),
                   rounds_media = median(ROUNDS_WIN,na.rm = T),
                   n = n(),
                   tx_win = 100*(sum(RESULTADO == "Vitória",na.rm=T) / n)) %>% 
          plot_ly(x = ~MAPA, y = ~duracao_media, type = 'bar',
               text = ~duracao_media, textposition = 'auto',
               marker = list(color = 'purple',
                             line = list(color = 'rgb(8,48,107)', width = 1.5))) %>%
                      layout(title = "Tempo médio (min)",
                      xaxis = list(title = ""),
                      yaxis = list(title = ""))


#### Tabela players ####

#seria interssante um filtro no shiny, por mapa, para essa analise#

tab2 <- db %>% group_by(JOGADOR) %>% 
  summarize(Partidas=n(),Kills_Media = mean(KILLS,na.rm=T),Total_Kills=sum(KILLS,na.rm=T),Kills_Min=min(KILLS,na.rm=T),
            Desvio_Kills = sd(KILLS,na.rm=T),Deaths_media=mean(MORTES,na.rm=T),
            Total_Deaths=sum(MORTES,na.rm=T),Score_media =mean(PONTOS,na.rm=T),
            Score_Total =sum(PONTOS,na.rm=T),Destaques_Media = mean(DESTAQUES,na.rm = T),
            Destaques_Total = sum(DESTAQUES,na.rm = T),KD_Medio=mean(KD,na.rm=T),KD_Max=max(KD,na.rm = T))

for(i in 2:ncol(tab2)){tab2[,i] <- round(tab2[,i],2)}



#achar uma tabela com layout top#
# DT::datatable(tab2,
#               rownames = FALSE,
#               options = list(pageLength = 10, autoWidth = TRUE))
