# HOME SERVER #

# GET USER PROFILE DATA FRAME
user_profile <- eventReactive(input$go, {
  
  # IF NULL ENTRY FROM USER
  if(input$user_id == '')
  {
    return('NO_ENTRY')
  }
  
  
  # USER ID
  db_profile <- CSGo::csgo_api_profile(
    api_key = api_key, 
    user_id = input$user_id, 
    name = is.na(as.numeric(input$user_id))
  )
  
  
  # RETURN
  return(db_profile)
  
})

# USER BOX
user_box <- eventReactive(input$go, {
  
  # IF NULL ENTRY FROM USER
  if(input$user_id == '')
  {
    user_return <- column(
      width = 12,
      class = 'home_welcome',
      HTML('<h3> Please fill the <b>Steam ID</b> and  <b>try again</b>!</h3>'))
    
    return(user_return)
  }
  
  
  # USER ID
  db_profile <- user_profile()
  
  
  # RETURN
  if(nrow(db_profile) == 0)
  {
    user_return <- column(
      width = 12,
      class = 'home_welcome',
      HTML('
          <h3>Please check if your accont status is <b>public</b>, 
           make sure your <b>Steam ID</b> is spelled correctly and <b>try again</b>!</h3>'))
    
    return(user_return)
  }
  
  else if(nrow(db_profile) != 0)
  {
    user_return <- column(
      width = 12,
      class = 'user_box',
      userBox(
        width = 8,
        title = userDescription(
          title = db_profile$personaname,
          subtitle = "",
          type = 1,
          image = db_profile$avatarfull
        ),
        collapsible = FALSE,
        HTML(
          paste0(
            '<a href="',
            db_profile$profileurl, 
            '" target="_blank" class="btn btn-steam"><i class="fa fa-steam left"></i></a>')
        ),
        footer = HTML(
          paste0(
            '<h4>Welcome <b>',
            db_profile$personaname, 
            '</b>, now you are able to use the entire page!</h4>')
        )
      )
    )
    
    return(user_return)
  }
  
  
})


# OUTPUTS
output$user_info <- renderUI(user_box())



