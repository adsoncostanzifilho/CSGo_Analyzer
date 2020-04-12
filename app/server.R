# server ----
server <- function(input, output, session)
{
  
  # USER BOX
  user_box <- eventReactive(input$go, {
    
    db_stats <- csgo_api_profile(key = api_key, user_id = input$user_id)
    
    if(nrow(db_stats) == 0)
    {
      user_return <- column(
        width = 12,
        class = 'home_welcome',
        HTML('
          <h3>Please check if your accont status is <b>public</b>, 
           make sure your <b>Steam ID</b> is spelled correctly and <b>try again</b>!</h3>')
      )
      
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
          footer = paste0('Welcome ', db_stats$personaname, ', now you are able to use the entire page!')
          
        )
      )
      
    }
    
    
  })
  
  
  
  
  
  
  
  # OUTPUTS
  output$user_info <- renderUI({user_box()})
}



