#- ABOUT TAB
about <- tabItem(
  tabName = "about",
  
  fluidRow(
    column(
      width = 12,
      class = 'home_welcome',
      h1(tags$b('CS Go Analyzer')),
      h3("A self-service interface designed to make it easier to analyze your own Counter-Strike Global Offensive data!"),
      br(),
      hr(class = "hr_about")
    ),
    
    column(
      width = 12,
      class = 'about_left',
      h2(tags$b('The Data:')),
      h3(
        "The data used in this interface is pulled", 
        tags$b("online"),
        "from",
        tags$a(
          class = "package_link",
          href="https://developer.valvesoftware.com/wiki/Steam_Web_API", 
          "Steam's API"),
         
        "through the R package", 
        tags$a(
          class = "package_link",
          href="https://adsoncostanzifilho.github.io/CSGo/", 
          tags$b("CSGo")),
        "."
      ),
      
      h2(tags$b('Developement:')),
      h3(
        "All the code used to develop this interface is available on",
        tags$a(
          class = "package_link", 
          href="https://github.com/adsoncostanzifilho/CSGo_Analyzer",
          "GitHub"),
        "and, as always, your feedback and contributions are much appreciated!",
        icon("smile-beam")
      ),
      
      br(),
      
      h2(tags$b('How does this interface work?')),
      h3(
        "The interface is divided into 3 main views, available on the left menu:", 
        tags$b("Home,"), 
        tags$b("Individual Data,"),
        "and", 
        tags$b("Friends Data.")
      ),
      
      h3(tags$b(icon("award"), "Home:")),
      h4(
        'The first thing you must do to use the entire interface is to jump on the',
        tags$b('Home'), 
        'tab on the left menu and collect some data.
        Once there, you must provide (any)',
        tags$b('Steam ID'),
        'and press',  tags$b('GO'),'!'
      ),
      h4(
        "If you don't have a Steam ID to search, feel free to use Rodrigo's ID (",
         tags$b("76561198263364899"),")!",
        class = "note"
      ),
      
      br(),
      
      h3(tags$b(icon("skull-crossbones"), "Individual Data:")),
      h4(
        "NICE! Now you can jump on the",
        tags$b("Individual Data"), 
        "tab to see some analysis on the player level.
        This tab will bring you the main KPIs as well as some analysis 
        regarding the best weapons and maps for the searched player!"
      ),
      
      br(),
      
      h3(tags$b(icon("book-dead"), "Friends Data:")),
      h4(
        "You can also go to the",
        tags$b("Friends Data"), 
        "tab to see how the player's friends are doing in the game!",
        "Here you will be able to compare the searched player among their friends**, 
        the best players to play with, and also the friend most similar to the searched player."
      ),
      
      tags$image(
        class = "sticker_about",
        src = 'img/CSGo_analyzer_sticker.PNG'
      ),
      
      br(),
      br(),
      hr(),
      h5(
        "**  To not overload Steam's API, it will be only considered the", 
        tags$b("30 most recent friends"),
        "of the searched player. You can collect all your friends' data by using the", 
        tags$b("get_stats_friends"), 
        "function from the CSGo package!",
      )

    )
  )
)