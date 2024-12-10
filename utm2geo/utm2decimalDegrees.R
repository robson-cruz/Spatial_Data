library(sf)
library(dplyr)
library(purrr)
library(stringr)


df <- data.frame(
    num_arvore = 1:4,
    flona = c("Caxiuanã", "Caxiuanã", "Caxiuanã", "Caxiuanã"),
    umf = c("1", "1", "2", "3"),
    upa = c("1", "1", "1", "1"),
    ut = c(1, 1, 1, 1),
    lat = c(-1.32, NA, -1.334, NA),
    lon = c(-51.21, NA, -52.445, NA),
    norte = c(NA, 9886047.581428, 9852505.4475075, NA),
    leste = c(NA, 487762.54801998, 339233.82662701, NA),
    zona_utm = c(NA, "22s", "22s", NA),
    mc = c(NA, "-51", "-51", NA)
)

# Filter rows that need an not need conversion
df_needs_conversion <- df %>%
    filter(is.na(lat) & !is.na(norte))

df_not_needs_conversion <- df %>%
    filter( (is.na(lat) & is.na(norte)) | (!is.na(lat) & !is.na(norte)) | (!is.na(lat) & is.na(norte)))

nrow(df_needs_conversion) + nrow(df_not_needs_conversion) == nrow(df)

# Function to convert UTM to lat/lon to each row
convert_coords <- function(leste, norte, zona_utm) {
    # Extracts the numeric UTM zone and determine hemisphere
    utm_zone <- as.numeric(str_extract(zona_utm, "\\d+"))
    southern <- grepl("s", zona_utm, ignore.case = TRUE)
    
    # Define the UTM CRS string
    utm_crs <- st_crs(
        paste0(
            "+proj=utm +zone=",
            utm_zone,
            if (southern) " +south" else "",
            " +ellps=GRS80 +towgs84=0,0,0,0,0,0,0 +units=m +no_defs"
        )
    )
    
    # Create an sf object and transform it
    point <- st_sfc(st_point(c(leste, norte)), crs = utm_crs)
    
    # Convert UTM to lat/lon (EPSG:4674)
    point_transformed <- st_transform(point, crs = 4674)
    
    # Extract lat/lon
    coords <- st_coordinates(point_transformed)
    return(c(lon = coords[1], lat = coords[2]))
}

# Apply the function
df_converted <- df_needs_conversion %>%
    rowwise() %>%
    mutate(
        coords = list(convert_coords(leste, norte, zona_utm)),
        lon = coords[1],
        lat = coords[2]
    ) %>%
    ungroup() %>%
    select(-coords)

# Combine converted and non-converted data
df_final <- bind_rows(df_converted, df_not_needs_conversion) %>%
    arrange(num_arvore, flona, umf, upa, ut)


head(df_final)
