# Carregue o pacote leaflet
library(leaflet)

# Função para converter graus, minutos e segundos em decimal
convertToDecimal <- function(degrees, minutes, seconds) {
        decimal <- degrees + minutes/60 + seconds/3600
        return(decimal*-1)
}

# Receba as coordenadas geográficas em graus, minutos e segundos

latitude_deg <- 02
latitude_min <- 18
latitude_sec <- 46

longitude_deg <- 51
longitude_min <- 48
longitude_sec <- 14

# Converta as coordenadas para decimal
#latitude_decimal <- convertToDecimal(latitude_deg, latitude_min, latitude_sec)
#longitude_decimal <- convertToDecimal(longitude_deg, longitude_min, longitude_sec)

latitude_decimal <- -3.03192504
longitude_decimal <- -49.75376764

# a single icon from fontawesome
awesome <- makeAwesomeIcon(
        #icon = "industry",
        #iconColor = "yellow",
        markerColor = "red",
        library = "fa"
)

# Crie um objeto de mapa usando leaflet
map <- leaflet() %>%
        #addProviderTiles("Esri") %>%
        addProviderTiles("OpenStreetMap") %>%
        setView(lng = longitude_decimal, lat = latitude_decimal, zoom = 15)
        #addMiniMap(position = "bottomleft", zoomLevelOffset = -10, zoomLevelFixed = TRUE)

# Adicione um marcador no ponto de coordenada
#map <- addAwesomeMarkers(icon = awesome, map, lng = longitude_decimal, lat = latitude_decimal)
map <- map %>% addMarkers(lng = longitude_decimal, lat = latitude_decimal)
# Exiba o mapa
map
