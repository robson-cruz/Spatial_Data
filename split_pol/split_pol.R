library(sf)


# Carregar o arquivo shapefile contendo o polígono
shapefile_path <- "~/polygon.shp"
poligono <- st_read(shapefile_path)

# Verificar a projeção do arquivo
print(st_crs(poligono))

# Calcular a área total do polígono em metros quadrados
area_total_m2 <- st_area(poligono)

# Definir o tamanho máximo de 100 hectares para cada polígono
tamanho_maximo_ha <- 100
tamanho_maximo_m2 <- tamanho_maximo_ha * 10000

# Criar uma grade que delimita a área do polígono
grid <- st_make_grid(poligono, cellsize = sqrt(tamanho_maximo_m2), what = "polygons")

# Dividir o polígono em polígonos menores com base na grade
poligonos_divididos <- st_intersection(poligono, grid)

# Salvar os polígonos divididos em um novo arquivo shapefile
novo_shapefile_path <- "~/polygons100ha.shp"
st_write(poligonos_divididos, novo_shapefile_path)
