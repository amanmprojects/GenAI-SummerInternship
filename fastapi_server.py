from fastapi import FastAPI
# from utils import getResults
import time
from services import WeaviateQueryService
print("All imports successfull")



query_service = WeaviateQueryService("Products")

while True:
    query_service.get_results(input("Enter a query: "), 10, True)
    print("\n")
    


# # init weaviate client
# client = weaviate.connect_to_local()
# products = client.collections.get("Products")



# print("All initializations complete")

# start = time.time()
# results = getResults("recommend me some sexy adidas tops girls", 10, model, products)
# end = time.time()
# # print(results)
# for result in results:
#     print(result.properties['productDisplayName'])

# print(f"time taken : {end-start} seconds")






app = FastAPI()

@app.get('/')
def getting():
    return "Hello world"


