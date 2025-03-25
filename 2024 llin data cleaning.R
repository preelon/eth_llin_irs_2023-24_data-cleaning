rm(list = ls())

#libraries
library("tidyverse")

#reading the 2024 llin data 
llin_2024 <- read_csv("data/raw/LLIN_2024.csv") 


#reading the shape file
shape_file <- read_csv("data/processed/eth_shape_file_updated.csv") |>
  janitor::clean_names() |>
  mutate(region= str_to_title(region),
         zone= str_to_title(zone),
         woreda= str_to_title(woreda))

#lets clean the llin_2024
names(llin_2024)

table(llin$id_1082) #no entries

#standardizing the 2024 llin dataset
llin_2024 <- llin_2024 |>
  janitor::clean_names() |>
  select(-id_1082)|> #removing the id_1082 col as there is no observation
  mutate(region_1082= str_to_title(region_1082),
         zone_1082= str_to_title(zone_1082),
         woreda_1082= str_to_title(woreda_1082))

#joining the 2024 llin data to the sf
llin_2024_sf_joined <- llin_2024 |>
  left_join(shape_file, by= c("region_1082" = "region", 
                              "zone_1082"= "zone", 
                              "woreda_1082" = "woreda"))

#lets see if there are unmatched observations
nm <- llin_2024_sf_joined |>
  filter(is.na(id_1082)) #no unmatched observation

#lets keep the cols we need before saving
llin_2024_sf_joined <- llin_2024_sf_joined |>
  select(id_1082,year,
         region= region_1082,
         zone= zone_1082,
         woreda= woreda_1082,
         ppl_received_llin= pop,
         net_distributed= net,
         source)

#saving the cleaned 2024 llin data
write.csv(llin_2024_sf_joined, "data/processed/2024_llin_cleaned.csv")
