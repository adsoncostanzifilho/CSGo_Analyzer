# server ----
server <- function(input, output, session)
{
  observe_helpers(withMathJax = TRUE)
  
  # USER BOX
  user_box <- eventReactive(input$go, {
    
    # IF NULL ENTRY FROM USER
    if(input$user_id == '')
    {
      user_return <- column(
        width = 12,
        class = 'home_welcome',
        HTML('
          <h3>Please check if your accont status is <b>public</b>, 
           make sure your <b>Steam ID</b> is spelled correctly and <b>try again</b>!</h3>'))
      
      return(user_return)
    }
    
    
    # USER ID
    db_stats <- csgo_api_profile(key = api_key, user_id = input$user_id)
    
    
    
    # USER NAME
    if(is.na(as.numeric(input$user_id)))
    {
      steam_id <- csgo_api_profile_by_name(key = api_key, username = input$user_id)
      db_stats <- csgo_api_profile(key = api_key, user_id = steam_id)
    }
    
    
    # RETURN
    if(nrow(db_stats) == 0)
    {
      user_return <- column(
        width = 12,
        class = 'home_welcome',
        HTML('
          <h3>Please check if your accont status is <b>public</b>, 
           make sure your <b>Steam ID</b> is spelled correctly and <b>try again</b>!</h3>'))
      
      return(user_return)
    }
    
    if(nrow(db_stats) != 0)
    {
      user_return <- column(
        width = 12,
        class = 'user_box',
        widgetUserBox(
          title = db_stats$personaname,
          subtitle = "",
          type = NULL,
          width = 8,
          src = db_stats$avatarfull,
          collapsible = FALSE,
          HTML(
            paste0(
              '<a href="',
              db_stats$profileurl, 
              '" target="_blank" class="btn btn-steam"><i class="fa fa-steam left"></i></a>')
          ),
          footer = HTML(paste0('<h4>Welcome <b>',
                          db_stats$personaname, 
                          '</b>, now you are able to use the entire page!</h4>'))
          
        )
      )
      
    }
    
    
  })
  
  
  
  
  
  
  
  # OUTPUTS
  output$user_info <- renderUI({user_box()})
}



