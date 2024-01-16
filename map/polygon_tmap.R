library(sp)
library(tmap)

# Load shp file
countries_spdf <- readRDS('./02_countries_spdf.rds')

# Use qtm() to create a choropleth map of gdp
qtm(shp = countries_spdf, fill = 'gdp')

# Load Europe data
world <- rnaturalearthdata::countries110
europe <- world[world$region_un == 'Europe' & world$name != 'Russia', ]

tm_shape(europe) +
        tm_borders() +
        tm_fill(col = 'admin') +
        # North arrow
        tm_compass() +
        tm_style('cobalt')


# Add style argument to the tm_fill() call
tm_shape(countries_spdf) +
        tm_fill(col = "population", style = "quantile") +
        # Add a tm_borders() layer 
        tm_borders(col = "burlywood4") 

# New plot, with tm_bubbles() instead of tm_fill()
tmap_mode('view')
tmap_mode('plot') # default

tm_shape(countries_spdf) +
        tm_bubbles(size = "population")  +
        tm_borders(col = "burlywood4") 

# Switch to a Hobo–Dyer projection - designed to preserve area.
tm_shape(countries_spdf, projection = '+proj=hd') +
        tm_grid(n.x = 11, n.y = 11) +
        tm_fill(col = "population", style = "quantile")  +
        tm_borders(col = "burlywood4") 

# Switch to a Robinson projection - designed as a compromise between preserving
# local angles and area.
tm_shape(countries_spdf, projection = '+proj=robin') +
        tm_grid(n.x = 11, n.y = 11) +
        tm_fill(col = "population", style = "quantile")  +
        tm_borders(col = "burlywood4") 

# Add tm_style("classic") to your plot
pop <- tm_shape(countries_spdf, projection = '+proj=robin') +
        tm_grid(n.x = 11, n.y = 11) +
        tm_fill(col = "population", style = "quantile")  +
        tm_borders(col = "burlywood4")  +
        tm_style('classic')

###>>> Saving a tmap plot <<<###
# Save a static version "population.png"
tmap_save(pop, './output/population.png')

# Save an interactive version "population.html"
tmap_last() %>%
        tmap_save(pop, './output/population.html')
