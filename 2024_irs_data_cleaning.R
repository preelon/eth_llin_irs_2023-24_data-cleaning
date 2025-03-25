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
  select(-id_1082) |>
  mutate(region_1082= str_to_title(region_1082),
         zone_1082= str_to_title(zone_1082),
         woreda_1082= str_to_title(woreda_1082))

#joining the IRS_2024 data to the shape file
irs_2024_sf_joined <- irs_2024 |>
  left_join(shape_file, by= c("region_1082"= "region",
                              "zone_1082"= "zone",
                              "woreda_1082" = "woreda"))

#lets see if there are unmatched districts
nm <- irs_2024_sf_joined |>
  filter(is.na(id_1082)) # there are 6 unmatched 

#lets deal with the 6 unmatched observations
irs_2024 <- irs_2024 |>
  mutate(zone_1082= case_when(woreda_1082 %in% c("Shinile", 
                                                 "Gota-Biki",
                                                 "Erer (Sm)") ~ "Siti",
                              woreda_1082== "Awra (Af)" ~ "Fanti /Zone 4",
                              woreda_1082 %in% c("Dulecha","Hanruka")  ~ "Gabi /Zone 3",
                              TRUE ~ zone_1082))
                            
#lets re-join and see if there are still unmatched observations
irs_2024_sf_joined <- irs_2024 |>
  left_join(shape_file, by= c("region_1082"= "region",
                              "zone_1082"= "zone",
                              "woreda_1082" = "woreda"))

nm <- irs_2024_sf_joined |>
  filter(is.na(id_1082)) # 0 unmatched 

#lets select the required columns before saving the cleaned data
irs_2024_sf_joined <- irs_2024_sf_joined |>
  select(id_1082, year,
         region= region_1082,
         zone= zone_1082,
         woreda= woreda_1082,
         irs_sprayed_hhs = irs_hs,
         source= souce)

#saving the cleaned data
write.csv(irs_2024_sf_joined, "data/processed/2024_irs_cleaned.csv")
