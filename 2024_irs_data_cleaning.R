rm(list = ls())

#libraries
library("tidyverse")

#reading the 2023 llin data 
irs_2024 <- read_csv("data/raw/IRS_2024.csv") 


#reading the shape file
shape_file <- read_csv("data/processed/eth_shape_file_updated.csv") |>
  janitor::clean_names() |>
  mutate(region= str_to_title(region),
         zone= str_to_title(zone),
         woreda= str_to_title(woreda))

#lets clean the llin_2024
names(irs_2024)

table(irs_2024$id_1082, useNA = "always") #32 entries

#standardizing the 2023 llin dataset
irs_2024 <- irs_2024 |>
  janitor::clean_names() |>
  mutate(region_1082= str_to_title(region_1082),
         zone_1082= str_to_title(zone_1082),
         woreda_1082= str_to_title(woreda_1082))