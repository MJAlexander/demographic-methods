library(tidyverse)
library(here)
df <- read_csv(here("data", "WPP2017_FERT_F07_AGE_SPECIFIC_FERTILITY.csv"), skip = 12)

df <- df %>% 
  rename(region = `Region, subregion, country or area *`, period = Period) %>% 
  select(-Index, -Variant, -Notes, -`Country code`) %>% 
  mutate(year = as.numeric(substr(period, 1, 4))) %>% 
  gather(age, Fx, -region, -period, -year) %>% 
  mutate(age = as.numeric(age), Fx = Fx/1000)

regions <- unique(df$region)

regions <- sort(regions[regions!=toupper(regions)])


# Use a fluid Bootstrap layout
fluidPage(    
  
  # Give the page a title
  titlePanel("Population projections"),
  
  # Generate a row with a sidebar
  sidebarLayout(      
    
    sidebarPanel(
      selectInput("region",label = "Region", choices = regions),
      sliderInput("number_proj",
                  "Project to year :",
                  value = 2020,
                  min = 2020,
                  max = 2200, 
                  step = 5,
                  sep = "", animate =
                    animationOptions(interval = 600, loop = FALSE)),
      helpText("Choose a region and the year to project population. Press play to see the projection. Data on 2010 populations, mortality, and fertility rates are from the UN Population Division World Population Prospects.")
      
    ),
    
    # Create a spot for the plot
    mainPanel(
      plotOutput("popPlot")  
    )
    
  )
)