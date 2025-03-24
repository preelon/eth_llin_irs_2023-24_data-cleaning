rm(list = ls())

#libraries
library("tidyverse")

#reading the 2023 llin data 
llin_2023 <- read_csv("data/raw/LLIN_2023.csv") 


#reading the shape file
shape_file <- read_csv("data/processed/eth_shape_file_updated.csv") |>
  janitor::clean_names() |>
  mutate(region= str_to_title(region),
         zone= str_to_title(zone),
         woreda= str_to_title(woreda))

#lets clean the llin_2023
names(llin_2023)

table(llin$id_1082) #no entries

#standardizing the 2023 llin dataset
llin_2023 <- llin_2023 |>
  janitor::clean_names() |>
  select(-id_1082)|> #removing the id_1082 col as there is no observation
  mutate(region_1082= str_to_title(region_1082),
         zone_1082= str_to_title(zone_1082),
         woreda_1082= str_to_title(woreda_1082))

#lets join the llin_2023 data to the shapefile to get the id_1082 and 
#standard adminstrative names
llin_2023_sf_joined <- llin_2023 |>
  left_join(shape_file, by= c("region_1082"= "region", 
                              "zone_1082"="zone", 
                              "woreda_1082"= "woreda"))

nm <- llin_2023_sf_joined |>
  filter(is.na(id_1082)) #21 unmatched

#lets correct the zone and woreda names based on the shapefile
llin_2023 <- llin_2023 |>
  mutate(region_1082= case_when(region_1082== "Oromiya" ~ "Oromia",
                                TRUE ~ region_1082)) |>
  mutate(woreda_1082= case_when(woreda_1082== "Bishan Guracha Town" ~ "Bishan Guracha",
                                woreda_1082== "Issera" ~ "Isara",
                                #woreda_1082== "Sulula Finchaa" ~ "Abay Chomen",
                                TRUE ~ woreda_1082)) |>
  mutate(zone_1082= case_when(woreda_1082 %in% c("Abaala", 
                                                 "Abaala Town", 
                                                 "Berahile", 
                                                 "Kunneba",
                                                 "Dalol",
                                                 "Afdera",
                                                 "Bidu") ~ "Kilbati /Zone 2",
                              woreda_1082 %in% c("Mile",
                                                 "Adar") ~ "Awsi /Zone 1",
                              woreda_1082 %in% c("Hadelela", 
                                                 "Samurobi", 
                                                 "Telalek",
                                                 "Dawe") ~ "Hari /Zone 5",
                              woreda_1082 %in% c("Yalo",
                                                 "Euwa",
                                                 "Gulina",
                                                 "Teru",
                                                 "Awra (Af)") ~ "Fanti /Zone 4",
                              #zone_1082== "HG/Wolega" ~ "Horo Gudru Wellega",
                              TRUE ~ zone_1082))
 #rejointhe sf and the 2023 llin data to see if the modification worked                             
llin_2023_sf_joined <- llin_2023 |>
  left_join(shape_file, by= c("region_1082"= "region", 
                              "zone_1082"="zone", 
                              "woreda_1082"= "woreda"))

nm <- llin_2023_sf_joined |>
  filter(is.na(id_1082)) #0 unmatched            

#selecting only the required cols before saving
llin_2023_sf_joined<- llin_2023_sf_joined |>
  select(id_1082,year,
         region= region_1082,
         zone= zone_1082,
         woreda= woreda_1082,
         ppl_received_llin= population_recieved,
         hhs_received_llin= h_hs,
         llin_dist_per_hhs = number_of_lli_ns_distributed_to_h_hs)
         

#save the cleaned 2023 llin dataset
write.csv(llin_2023_sf_joined, "data/processed/2023_llin_cleaned.csv") 
                                          
                                                


 
 