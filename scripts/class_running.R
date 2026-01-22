library(rnaturalearth)
library(dplyr)
library(sf)
library(ggplot2)

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
