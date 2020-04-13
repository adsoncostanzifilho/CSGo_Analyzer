

# using UFPR mirror to download packages
repository_url <- "http://cran-r.c3sl.ufpr.br/"

install_load <- function (package1, ...)  {   
  
  # convert arguments to vector
  packages <- c(package1, ...)
  
  # start loop to determine if each package is installed
  for(package in packages){
    
    # if package is installed locally, load
    if(package %in% rownames(installed.packages()))
      do.call('library', list(package))
    
    # if package is not installed locally, download, then load
    else {
      install.packages(package,repos = repository_url)
      do.call("library", list(package))
    }
  } 
}



packages <- c("devtools","dplyr","purrr","stringr","tidyverse",
              "stringdist","data.table","dbplyr","lubridate",
              "visdat","janitor","furrr","profvis","htmlwidgets","parallel","fastmatch","plotly","ggplot2",
              "formattable","readxl")

install_load(packages)

# installing a specific H2O version
#install_version("h2o", version="3.20.0.2", repos=repository_url)
