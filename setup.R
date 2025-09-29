# Script for installing (if needed) and loading packages for this project
  # Adapted from Katie Willi (github: kathryn-willi)

packageLoad <- function(x) {
  for (i in 1:length(x)) {
    if (!x[i] %in% installed.packages()) {
      install.packages(x[i])
    }
    library(x[i], character.only = TRUE)
  }
}

# create a string of package names

packages <- c('here',
              'tidyverse',
              'nhdplusTools',
              'ggthemes',
              'sp',
              'sf',
              'prettymapr',
              'rosm',
              # 'mapview',
              'terra',
              'lwgeom')
# use the packageLoad function we created on those packages

packageLoad(packages)