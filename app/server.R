#--- SERVER ---#
server <- function(input, output, session) 
{
  #- Help buttons
  observe_helpers(withMathJax = TRUE)
  
  # Home Server
  source('tabs/1_home/home_server.R', local = TRUE)
  
  # Individual Data Server
  source('tabs/2_me/me_server.R', local = TRUE)
  
  # Friends Data Server
  source('tabs/3_friends/friends_server.R', local = TRUE)
  
}



