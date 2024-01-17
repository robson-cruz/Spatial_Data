library(dplyr, warn.conflicts = FALSE)
library(sf)
library(tmap)


# Forest Concession in Pará State
conces_pa <- c('FLORESTA NACIONAL DE CAXIUANÂ', 'FLORESTA NACIONAL DO CREPORI',
               'FLORESTA NACIONAL DE SARACÁ-TAQUERA', 
               'FLORESTA NACIONAL DE ALTAMIRA')

# Load shapefile data
flonas <- st_read(
        'E:/spatial_data/icmbio/uc_fed_julho_2019/uc_fed_julho_2019.shp',
        options = 'ENCONDING=latin1'
) %>%
        filter(UF == 'PA' & sigla == 'FLONA') %>%
        rename('Hectares' = 'areaHa') %>%
        rename_all(toupper)

flonas_conces <- flonas %>%
        filter(UF == 'PA' & SIGLA == 'FLONA' & NOME %in% conces_pa) %>%
        select('NOME', 'HECTARES', 'MUNICIPIOS')

upas <- sf::st_read(
        'E:/repositories/concessaoFlorestal/data/upas_concessao_pa_20230322/upas_concessao_pa_20221206.shp', 
        options = 'ENCODING=latin1'
)

umf <- st_read(
        'E:/repositories/concessaoFlorestal/data/umf_concessao_pa/umf_concessao_pa.shp',
        options = 'ENCODING=latin1'
) %>%
        mutate(hectares = as.numeric(hectares))

pa_boundaring <- st_read('E:/spatial_data/ibge/BR_UF_2021/BR_UF_2021.shp') %>%
        filter(SIGLA == "PA")

cxn_umf3 <- upas %>%
        filter(UMF == 3 & FLONA == 'Caxiuanã')

## Plots with tm_plot package
# tm_polygons plots polygons with fill around each polygon
# tm_borders without fill
tmap_mode('view') # Interactive maps
flonas_map <- tm_shape(pa_boundaring) +
        tm_borders(lwd = 2) +
        tm_shape(flonas) +
        tm_fill('darkolivegreen3', 
                alpha = .75, 
                id = 'NOME',
                popup.vars = c('Hectares' = 'HECTARES', 'Municípios' = 'MUNICIPIOS'),
                popup.format = list(HECTARES = list(digits = 2, decimal.mark = ',', big.mark = '.'))) +
        tm_shape(flonas_conces) +
        tm_borders(col = 'red') +
        #tm_text('NOME', size = 0.5) +
        tm_compass(north = 0, position = c('right', 'top'), size = 1, type = '8star') +
        tm_minimap(server = 'OpenStreetMap', position = c('right', 'bottom')) +
        tm_basemap(server = 'OpenStreetMap')
        

umf_map <- tm_shape(umf) +
        tm_polygons(col = NA, 
                    border.col = 'red', 
                    alpha = 0.5,
                    id = 'umf',
                    popup.var = c('Flona' = 'flona', 'Concessionária' = 'conces', 
                                  'Hectares' = 'hectares'),
                    popup.format = list(
                            hectares = list(digits = 2, 
                                            decimal.mark = ',', 
                                            big.mark = '.'))
                    ) +
        tm_text('umf', size = 0.8, remove.overlap = TRUE) +
        tm_facets(sync = FALSE, ncol = 2, by = 'flona') +
        tm_basemap(server = 'OpenStreetMap') +
        tm_mouse_coordinates() +
        tmapOutput(outputId = 'umf_screen', height = '100%')
        

        
## save an image ("plot" mode)
tmap_save(flonas_map, filename = "flonas_map.png")
tmap_save(umf_map, filename = "umf_pa.png")


## save as stand-alone HTML file ("view" mode)
# tmap_save(umf_map, filename = "umf_pa.html")
