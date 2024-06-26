import weaviate # type: ignore
import weaviate.classes as wvc # type: ignore
# import numpy as np
import pandas as pd # type: ignore
from sentence_transformers import SentenceTransformer # type: ignore
import warnings
import argparse


# Suppressing warning
warnings.filterwarnings("ignore", category=FutureWarning, message=".*resume_download.*")




# Handling arguments for python Scripts
def main(arg1, arg2, arg3):
    print(f'Model: {arg1}')
    print(f'Weaviate Collection : {arg2}')
    print(f'CSV Path : {arg3}')

MODEL_DICT = {
    'mini-6' : "all-MiniLM-L6-v2",
    "mini-12" : 'all-MiniLM-L12-v2',
    'paraphrase-6' : "paraphrase-MiniLM-L6-v2",
    'paraphrase-12' : "paraphrase-MiniLM-L12-v2",
}
# MODEL_LIST = ["sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2", "paraphrase-MiniLM-L6-v2", "all-MiniLM-L6-v2", "paraphrase-MiniLM-L12-v2"]
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Script for creating a weaviate Database from CSV")
    parser.add_argument('--model', type=str, default='paraphrase-6', help='Set the Vectorizer Model from the given : '.join(MODEL_DICT.keys()).join(MODEL_DICT.values()))
    parser.add_argument('--col', type=str, default='Products', help='Set the Collection in weaviate Database')
    parser.add_argument('--csv', type=str, default='datasets_csv/Products.csv', help='Set the path of CSV to vectorize and insert in DB')
    args = parser.parse_args()
    main(args.model, args.col, args.csv)


MODEL_NAME = MODEL_DICT[args.model]
collection_name = args.col
CSV_PATH = args.csv 





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
# averageRatings = column_lists['averageRating']id
# numberOfRatings = column_lists['numberOfRatings']
# Prices = column_lists['Price']




# Setting the text that will converted to vector and stored in the database
texts_to_vectorize = column_lists['description']


# Encoding/Vectorize/Embedding the texts_toVectorize
vectors = model.encode(texts_to_vectorize)


# Creating a weaviate client and connection to the weaviate running in docker
client = weaviate.connect_to_local()



# Creating a fresh collection in weaviate Vector DB
if client.collections.exists(collection_name):
    client.collections.delete(collection_name)
products = client.collections.create(
    collection_name,
    vectorizer_config=wvc.config.Configure.Vectorizer.none()
)




# Creating a list of wvc.data.DataObject in put in product.data.insert_many()
prod_objs = [
    wvc.data.DataObject(
        properties = {
            'product_id': column_lists['id'][i],
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
            'Price' : column_lists['Price'][i],
            'imagePath' : f"images/{column_lists['id'][i]}.jpg"
        },
        vector = vectors[i].tolist()
    )
    for i in range(len(df))
]

products = client.collections.get(collection_name)
products.data.insert_many(prod_objs)

client.close()


