library(shiny)
library(shinythemes)

### set initial values
t <- 12 # time to play
stock0 <- matrix(0, nrow = t + 1, ncol = 2)
stock0[1, 1] <- 500 # initial stock
stockMin <- stock0[1, 1] * 0.4 # minimum stock before collapse (proportion of starting stock)
nActors <- 5 # max number of competitors
allActors <- FALSE # are all actors present at each timestep?
take <- 0.6 # "sustainable" take 
