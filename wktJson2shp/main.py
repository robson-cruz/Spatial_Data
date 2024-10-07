import requests
import json
import pandas as pd
import geopandas
from shapely import wkt


URL = f"https://corpgateway-api.ibama.gov.br/sicafiservicecorp/api/v1/public/termo/consultar/embargos/wkt?seqTad="


def get_data(seq_tad, url):
    url = f"{url}{seq_tad}"

    response = requests.get(url=url)

    if response.status_code == 200:
        # Get API data as a json
        data = response.json()
        with open('json_data.json', 'w', encoding='utf-8') as f:
            json.dump(data, f, ensure_ascii=False, indent=4)

        wkt_to_shp(data)

    elif response.status_code == 404:
        raise Exception("Dados não encontrados na API!")
    else:
        raise Exception("Não foi possível acessar os dados requsitados na API!")


def wkt_to_shp(data):
    # Check if the 'wktGeomAreaEmbargada' key exists ib=n the json
    if 'wktGeomAreaEmbargada' in data:
        # Converts the json to pandas DataFrame
        df = pd.DataFrame([data])

        # Convert wkt column to geometry
        df['geometry'] = df['wktGeomAreaEmbargada'].apply(wkt.loads)

        # Create a GeoDataFrame
        gdf = geopandas.GeoDataFrame(df, geometry='geometry')

        # Define the coordinate system
        gdf.set_crs(epsg=4674, inplace=True)

        # Save the GeoDataFrame as a shapefile
        gdf.to_file('shp_data.shp', driver='ESRI Shapefile')
        print("Arquivo shapefile salvo com sucesso!")
        # Save the data as GeoJSON
        gdf.to_file('GeoJson_data.geojson', driver='GeoJSON')
    else:
        raise Exception("Chave 'wktGeomAreaEmbargada' não encontrada no JSON!")


# Call the function with the 'seqTad'
get_data(1852258, URL)
