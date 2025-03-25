rm(list = ls())

#libraries
library("tidyverse")

#reading the 2023 IRS data 
irs_2023 <- read_csv("data/raw/IRS_2023.csv") 


#reading the shape file
shape_file <- read_csv("data/processed/eth_shape_file_updated.csv") |>
  janitor::clean_names() |>
  mutate(region= str_to_title(region),
         zone= str_to_title(zone),
         woreda= str_to_title(woreda))

#lets clean the llin_2023
names(irs_2023)

table(irs_2023$id_1082, useNA = "always") #469 NAs

#standardizing the IRS dataset
irs_2023 <- irs_2023 |>
  janitor::clean_names() |>
  select(-id_1082) |>
  mutate(region_1082= str_to_title(region_1082),
         zone_1082= str_to_title(zone_1082),
         woreda_1082= str_to_title(woreda_1082))

#lets join the shape file and the 2023 irs data
irs_2023_sf_joined <- irs_2023 |>
  left_join(shape_file, by= c("region_1082"= "region",
                              "zone_1082"= "zone",
                              "woreda_1082"= "woreda"))

#lets check unmatched observations
nm <- irs_2023_sf_joined |>
  filter(is.na(id_1082)) #18 obs

#lets deal with some of the unmatched obs
irs_2023 <- irs_2023 |>
  mutate(woreda_1082= case_when(woreda_1082== "Dewe" ~ "Dawe",
                                woreda_1082== "Godare" ~ "Godere",
                                woreda_1082== "Mengeshi" ~ "Mengesh",
                                TRUE ~ woreda_1082))

#lets re-join the shape file and the 2023 irs data
irs_2023_sf_joined <- irs_2023 |>
  left_join(shape_file, by= c("region_1082"= "region",
                              "zone_1082"= "zone",
                              "woreda_1082"= "woreda"))

#lets check unmatched observations
nm <- irs_2023_sf_joined |>
  filter(is.na(id_1082)) #15 obs,I couldn't match them because no woreda is 
                         #specified in the original doc

#selecting the required cols before saving the cleaned data
irs_2023_sf_joined <- irs_2023_sf_joined |>
  select(id_1082, year,
         region= region_1082,
         zone= zone_1082,
         woreda= woreda_1082,
         hs_sprayed, 
         population_projected)

#saving the cleaned data
write.csv(irs_2023_sf_joined, "data/processed/2023_irs_cleaned.csv")
