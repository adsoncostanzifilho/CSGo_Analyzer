#--- SERVER ---#
server <- function(input, output, session) 
{
  #- Help buttons
  observe_helpers(withMathJax = TRUE)
  
  # Home Server
  source('tabs/1_home/home_server.R', local = TRUE)  
  
}



