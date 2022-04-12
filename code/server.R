library(tidyverse)
library(here)
library(patchwork)
df <- read_csv(here("data", "WPP2017_FERT_F07_AGE_SPECIFIC_FERTILITY.csv"), skip = 12)

df <- df %>% 
  rename(region = `Region, subregion, country or area *`, period = Period) %>% 
  select(-Index, -Variant, -Notes, -`Country code`) %>% 
  mutate(year = as.numeric(substr(period, 1, 4))) %>% 
  gather(age, Fx, -region, -period, -year) %>% 
  mutate(age = as.numeric(age), Fx = Fx/1000)

dl <- read_csv(here("data", "WPP2017_MORT_F17_3_ABRIDGED_LIFE_TABLE_FEMALE.csv"), skip = 16)

dl <- dl %>% 
  rename(region = `Region, subregion, country or area *`,
         Lx = `Number of person-years lived L(x,n)`,
         age = `Age (x)`,
         period = Period) %>% 
  select(region, period, age, Lx) %>% 
  mutate(year = as.numeric(substr(period, 1, 4)), Lx = Lx/10^5)

leslie <- function(nLx,
                   nFx, 
                   n_age_groups=17,
                   ffab = 0.4886){
  L = matrix(0, nrow = n_age_groups, ncol = n_age_groups)
  L[1,] = ffab * nLx[1]*(nFx[1:n_age_groups]+nFx[2:(n_age_groups+1)]*nLx[2:(n_age_groups+1)]/nLx[1:n_age_groups])/2 # top row 
  L[1,ncol(L)] <- 0
  diag(L[2:n_age_groups,1:(n_age_groups-1)]) = nLx[2:n_age_groups] / nLx[1:(n_age_groups-1)] # subdiagonal
  return(L)
}

d_female <- read_csv(here("data", "WPP2017_POP_F15_3_ANNUAL_POPULATION_BY_AGE_FEMALE.csv"), skip = 12)



# Define a server for the Shiny app
function(input, output) {
  
  # Fill in the spot we created for a plot
  output$popPlot <- renderPlot({
    
    nLx <- dl %>% 
      left_join(df) %>% 
      filter(year==2010, region == input$region, age<85) %>% 
      select(Lx) %>% pull()
    
    ## need to fix first age group
    
    nLx <- c(sum(nLx[1:2]), nLx[3:length(nLx)])
    
    nFx <- dl %>% 
      left_join(df) %>% 
      filter(year==2010, region == input$region) %>% 
      mutate(Fx = ifelse(is.na(Fx), 0, Fx)) %>% 
      select(Fx) %>% pull()
    
    nFx <- nFx[-1]
    
    A <- leslie(nLx, nFx)
    
    Kt <- d_female %>% 
      rename(region = `Region, subregion, country or area *`,
             year = `Reference date (as of 1 July)`) %>% 
      select(-Index, -Variant, -Notes, -`Country code`) %>% 
      filter(region==input$region, year==2010) %>% 
      gather(age, pop, -region, -year) %>% 
      mutate(age = as.numeric(age)) %>% 
      filter(age<85) %>% 
      mutate(pop = as.numeric(pop)) %>% 
      select(pop) %>% 
      pull()
    
    
    age_groups <- seq(0, 80, by = 5)
    n_age_groups <-  length(age_groups)
    n_projections <- (input$number_proj - 2010)/5
    initial_pop <- Kt
    # define population matrix K
    K <- matrix(0, nrow = n_age_groups, ncol = n_projections+1)
    K[,1] <- Kt[1:n_age_groups]
    
    # do the projection!
    for(i in 2:(n_projections+1)){
      K[,i] <- A%*%K[,i-1] 
    }
    
    Kdf <- as_tibble(K)
    colnames(Kdf) <- seq(from = 2010, to = (2010+n_projections*5), by = 5)
    Kdf <- cbind(age = seq(from = 0, to = 80, by = 5), Kdf)
    
    # get in long format and then add proportion of population in each age group
    dk <- Kdf %>% 
      gather(year, population, -age) %>%
      mutate(year = as.numeric(year)) %>% 
      group_by(year) %>%
      mutate(proportion = population/sum(population))
    
    
    p1 <- dk %>% 
      group_by(year) %>% 
      summarise(pop = sum(population)) %>% 
      ggplot(aes(year, pop)) + geom_line(lwd = 1.5) + 
      ggtitle("Total population")+
      theme_bw(base_size = 14)+
      xlim(c(2020, 2200))
    p2 <- dk %>% 
      filter(age %in% seq(0, 80, by = 10)) %>% 
      mutate(age = factor(age)) %>% 
      ggplot(aes(year, proportion, color = age)) + 
      geom_line(lwd = 1.5) + 
      ggtitle("Proportion by age group")+
      theme_bw(base_size = 14)+
      xlim(c(2020, 2200))
    
    p1+p2
    
  })
}