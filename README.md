# CS GO Analyzer <img src="app/www/img/CSGo_analyzer_sticker.PNG" align="right" width="120" />

<br>

## Overview

The **CS GO Analyzer** is a self-service interface (powered by R and
`shiny`) designed to make it easier to analyze your own Counter-Strike
Global Offensive data. If you like **CS GO** and **R** probably you will
enjoy this repository!

The tool is online on shinyapps’ repository at the address
<https://adsoncostanzi.shinyapps.io/csgoanalyzer/>.

*PS*: To run this interface locally it is necessary to have your own
Steam’ credentials (API Key). You will find
[here](https://adsoncostanzifilho.github.io/CSGo/articles/auth.html) the
guidance on how to get a Steam’ API Key, or with you prefer you can run
`vignette("auth", package = "CSGo")` in R.

Then you must create a file called “api\_key.R” inside the “credentials”
folder (app&gt;credentials&gt;api\_key.R) assigning your API key to an
object called api\_key, like this:

`api_key <<- 'YOUR API KEY'`

## The Data

The data used in this interface is pulled online from [Steam’s
API](https://developer.valvesoftware.com/wiki/Steam_Web_API) through the
R package [CSGo](https://adsoncostanzifilho.github.io/CSGo/).

## How does this interface work?

The interface is divided into 3 main views, available on the left menu:
**Home**, **Individual Data**, and **Friends Data**.

### Home:

The first thing you must do to use the entire interface is to jump on
the Home tab on the left menu and collect some data. Once there, you
must provide (any) Steam ID and press GO !

PS: If you don’t have a Steam ID to search, feel free to use Rodrigo’s
ID ( 76561198263364899 )!

### Individual Data:

NICE! Now you can go to the Individual Data tab to see some analysis on
the player level. This tab will bring you the main KPIs as well as some
analysis regarding the best weapons and maps for the searched player!

### Friends Data:

You can also go to the Friends Data tab to see how the player’s friends
are doing in the game! Here you will be able to compare the searched
player among their friends, the best players to play with, and also the
friend most similar to the searched player.

![](app/www/img/csgo_demo.gif)
