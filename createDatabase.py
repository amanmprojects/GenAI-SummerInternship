import weaviate
import os
import weaviate.classes as wvc
import requests
import json
import numpy as np
import pandas as pd
from sentence_transformers import SentenceTransformer
import warnings
# Suppress specific warning
warnings.filterwarnings("ignore", category=FutureWarning, message=".*resume_download.*")

CSV_PATH = "/home/amanm/GenAI-Repo/GenAI-SummerInternsip/Products.csv"
MODEL_NAME = "all-MiniLM-L6-v2"


# Setting the model
model = SentenceTransformer(MODEL_NAME)



# Importing the CSV
df = pd.read_csv(CSV_PATH, on_bad_lines="skip")

# Initialize an empty dictionary to store lists
column_lists = {}

# Iterate through each column in the DataFrame
for column in df.columns:
    column_lists[column] = df[column].tolist()



# Example Access
# displayNames = column_lists['productDisplayName']
# masterCategories = column_lists['masterCategory']
# subCategories = column_lists['subCategory']
# articleTypes = column_lists['articleType']
# baseColours = column_lists['baseColour']
# seasons = column_lists['season']
# years = column_lists['year']
# usages = column_lists['usage']
# descriptions = column_lists['description']
# averageRatings = column_lists['averageRating']
# numberOfRatings = column_lists['numberOfRatings']
# Prices = column_lists['Price']




# Setting the text that will converted to vector and stored in the database
texts_to_vectorize = column_lists['description']


# Encoding/Vectorize/Embedding the texts_toVectorize
vectors = model.encode(texts_to_vectorize)


# Creating a weaviate client and connection to the weaviate running in docker
client = weaviate.connect_to_local()



# Creating a fresh collection in weaviate Vector DB
if client.collections.exists("Products"):
    client.collections.delete("Products")
products = client.collections.create(
    "Products",
    vectorizer_config=wvc.config.Configure.Vectorizer.none()
)




# Creating a list of wvc.data.DataObject in put in product.data.insert_many()
prod_objs = [
    wvc.data.DataObject(
        properties = {
            'productDisplayName' : column_lists['productDisplayName'][i],
            'masterCategory' : column_lists['masterCategory'][i],
            'subCategory' : column_lists['subCategory'][i],
            'articleType' : column_lists['articleType'][i],
            'baseColour' : column_lists['baseColour'][i],
            'season' : column_lists['season'][i],
            'year' : column_lists['year'][i],
            'usage' : column_lists['usage'][i],
            'description' : column_lists['description'][i],
            'averageRating' : column_lists['averageRating'][i],
            'numberOfRatings' : column_lists['numberOfRatings'][i],
            'Price' : column_lists['Price'][i]
        },
        vector = vectors[i].tolist()
    )
    for i in range(len(df))
]

products = client.collections.get("Products")
products.data.insert_many(prod_objs)

client.close()


