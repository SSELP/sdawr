library(rnaturalearth)
library(dplyr)
library(sf)
library(ggplot2)
library(terra)

cnt_nms <- c("Latvia", "India", "Switzerland", "Pakistan", 
             "People's Republic of China", "Italy", 
             "United States of America", "France", "Barbados", 
             "Egypt", "Canada", "Finland")

# Query boundary of Colombia
all_cnts <- ne_countries(scale = 110)

cnts <- all_cnts %>% filter(name_en %in% cnt_nms) %>% 
    bind_cols(st_coordinates(st_centroid(cnts)))

ggplot() +
    geom_sf(data = all_cnts, fill = "grey", color = "grey") +
    geom_sf(data = cnts, fill = "#ffd166", color = "black") +
    geom_text(
        data = cnts, 
        aes(x = X, y = Y, label = adm0_a3_pk), 
        position = position_dodge(1)) +
    theme_void()

# Get tropical bird data
library(rgbif)
birds <- c("Harpia harpyja", "Ara macao", 
           "Ramphastos sulfuratus", "Amazilia tzacatl")
clean_keys <- name_backbone_checklist(birds) %>% pull(usageKey)

download_job <- occ_download(
    pred_in("taxonKey", clean_keys),
    pred("occurrenceStatus", "PRESENT"),
    pred("hasCoordinate", TRUE),
    pred("hasGeospatialIssue", FALSE),
    pred_gte("distanceFromCentroidInMeters", 10), 
    pred("taxonomicStatus", "ACCEPTED"), 
    pred_gte("year", 1980), 
    format = "SIMPLE_CSV")

occ_download_get(download_job, path = ".", overwrite = TRUE)
dat <- read.delim("0010202-260208012135463.csv") %>% 
    select(family, species, decimalLatitude, decimalLongitude,
           day, month, year)

vars <- rast("bioclim.tif")

vars <- extract(
    subset(vars, c("bio01", "bio12")), 
    dat %>% st_as_sf(coords = c("decimalLongitude", "decimalLatitude"), 
                     crs = 4326) %>% st_transform(crs(vars)))

dat <- cbind(dat, vars) %>% 
    select(family, species, decimalLatitude, decimalLongitude, month, year, bio01, bio12) %>% 
    rename(latitude = decimalLatitude, longitude = decimalLongitude,
           temperature = bio01, precipitation = bio12)
write.csv(dat, 'tropical_birds.csv', row.names = TRUE)

# Get Spotted Hyenas data
clean_keys <- name_backbone_checklist("Crocuta crocuta") %>% pull(usageKey)

download_job <- occ_download(
    pred_in("taxonKey", clean_keys),
    pred("occurrenceStatus", "PRESENT"),
    pred("hasCoordinate", TRUE),
    pred("hasGeospatialIssue", FALSE),
    pred_gte("distanceFromCentroidInMeters", 10), 
    pred("taxonomicStatus", "ACCEPTED"), 
    pred_gte("year", 1980), 
    format = "SIMPLE_CSV")

occ_download_get(download_job, path = ".", overwrite = TRUE)
occurrence <- read.delim("0001734-260221153910048.csv") %>% 
    dplyr::select(gbifID, species, countryCode, 
                  decimalLatitude, decimalLongitude, 
                  day, month, year) %>% 
    filter(countryCode != "") %>% 
    filter(!countryCode %in% c("US", "PH")) %>% 
    na.omit() %>% distinct() %>% 
    st_as_sf(coords = c('decimalLongitude', 'decimalLatitude'),
             crs = 4326)

bios <- rast(list.files("/Users/leisong/downloads/wc2", full.names = TRUE))
variables <- extract(bios, occurrence, ID = FALSE, bind = TRUE) %>%
    st_as_sf() %>% st_drop_geometry() %>% 
    dplyr::select(c('gbifID', paste0('wc2.1_2.5m_bio_', 1:19)))
write.csv(variables, 'docs/hyenas_variables.csv', row.names = FALSE)

occurrence <- read.delim("0001734-260221153910048.csv") %>% 
    filter(gbifID %in% variables$gbifID)
write.csv(occurrence, 'docs/hyenas_occurrence.csv', row.names = FALSE)
