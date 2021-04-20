# USER WELCOME
user_welcome <- eventReactive(input$go, {
  
  db_profile <- user_profile()

  welcome <- column(
    width = 12,
    class = 'home_welcome',
    h1(tags$b(db_profile$personaname)),
    br(),
    hr()
  )
  
  return(welcome)
})

# USER STATS
user_stats <- eventReactive(input$go, {
  
  user_stats <- get_stats_user(api_key = api_key, user_id = '76561198263364899')
  
})

main_kpis <- eventReactive(input$go, {
  
  user_stats <- user_stats()
  
 kpi <- column(
   width = 12,
   class = 'home_welcome',
   
   column(
     width = 3,
     class = "side_side",
     valueBox(
       width = 10,
       value = formatC(
         round(filter(user_stats, name == 'total_kills') %>% .$value /
           filter(user_stats, name == 'total_deaths') %>% .$value, 2),
         big.mark=','
       ),
       subtitle = "Kills / Deaths",
       icon = icon("skull-crossbones"),
       color = "purple")
   ),
   
   column(
     width = 3, 
     class = "side_side",
     valueBox(
       width = 10,
       value = formatC(
         user_stats %>%
           filter(name == 'total_mvps') %>%
           .$value,
         big.mark=','
       ),
       subtitle = "Total MVPs",
       icon = icon("crosshairs"),
       color = "purple")
   ),
   
   column(
     width = 3,
     class = "side_side",
     valueBox(
       width = 10,
       value = formatC(
         user_stats %>%
           filter(name == 'total_wins') %>%
           .$value,
         big.mark=','
       ),
       subtitle = "Total Wins",
       icon = icon("trophy"),
       color = "purple")
   ),
   
   column(
     width = 3,
     class = "side_side",
     valueBox(
       width = 10,
       value = formatC(
         user_stats %>%
           filter(name == 'total_time_played') %>%
           .$value,
         big.mark=','
       ),
       subtitle = "Time Played",
       icon = icon("clock"),
       #icon = icon("stats", lib='glyphicon'),
       color = "purple")
   )

 )
  
  
  return(kpi)
  
})











# OUTPUTS
output$user_welcome <- renderUI(user_welcome())
output$main_kpis <- renderUI(main_kpis())
