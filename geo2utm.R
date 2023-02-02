library(dplyr, warn.conflicts = FALSE)
library(sf)


# Load data
pol <- st_read('~/car/AREA_IMOVEL_1.shp')
utm_grid <- st_read('~/car/World_UTM_Grid.shp') %>%
        select(ZONE, ROW_, CM_VALUE) %>%
        filter(CM_VALUE %in% c('45W', '51W', '57W'))

# Re-project data to EPSG:5880 (SIRGAS 2000 / Brazil Polyconic)
pol <- st_transform(pol, 5880)

utm_grid <- st_transform(utm_grid, 5880)

# Join data
pol_join <- st_join(pol, utm_grid, join = st_nearest_feature)

# Remove overlaps and Re-project it according the UTM zone and central meridian
pol_21S <- pol_join %>% filter(ZONE == 21)
pol_22S <- pol_join %>% filter(ZONE == 22)
pol_23S <- pol_join %>% filter(ZONE == 23)

overlaps_21_22 <- st_filter(pol_21S, pol_22S, .predicate = st_overlaps)
overlaps_22_21 <- st_filter(pol_22S, pol_21S, .predicate = st_overlaps)
overlaps_22_23 <- st_filter(pol_22S, pol_23S, .predicate = st_overlaps)
overlaps_23_22 <- st_filter(pol_23S, pol_22S, .predicate = st_overlaps)

pol_21S <- pol_21S[overlaps_22_21, ]
pol_21S <- st_transform(pol_21S, 31981)
pol_22S <- pol_22S[overlaps_21_22, ]
pol_22S <- pol_22S[overlaps_23_22, ]
pol_22S <- st_transform(pol_22S, 31982)
pol_23S <- pol_23S[overlaps_22_23, ]
pol_23S <- st_transform(pol_23S, 31983)

# Save as .shp
st_write(pol_21S, '~/car/pol_21s.shp', layer = 'ESRI Shapefile')
st_write(pol_22S, '~/car/pol_22s.shp', layer = 'ESRI Shapefile')
st_write(pol_23S, '~/car/pol_23s.shp', layer = 'ESRI Shapefile')
