from fastapi import FastAPI, UploadFile, File, Response, Query # type: ignore      
from fastapi.responses import FileResponse, StreamingResponse, JSONResponse # type: ignore
from io import BytesIO   
import os
import time
from services import WeaviateQueryService
from pydantic import BaseModel # type: ignore
from typing import List
print("All imports successfull")



wv_query_service = WeaviateQueryService("Products")




app = FastAPI()

# print("All initializations complete")


class ProductResponse(BaseModel):
    id: int
    displayNames: str
    masterCategories: str
    subCategories: str
    articleTypes: str
    baseColours: str
    seasons: str
    years: int
    usages: str
    descriptions: str
    averageRatings: float
    numberOfRatings: int
    # Prices: str
    imagePath: str
    class Config:
        orm_mode = True




@app.post("/query", response_model=List[ProductResponse])
async def get_product_details(query: str = "General Products", top_n: int = 10, groq_simplify: bool = True):
    products = wv_query_service.get_results(query=query, top_n=top_n, groq_llama_simplfy=groq_simplify,print_responses_name=True)
    response = []

    for product in products:
        response.append(ProductResponse(
            id = product.properties ['product_id'],
            displayNames=product.properties['productDisplayName'],
            masterCategories=product.properties['masterCategory'],
            subCategories=product.properties['subCategory'],
            articleTypes=product.properties['articleType'],
            baseColours=product.properties['baseColour'],
            seasons=product.properties['season'],
            years=product.properties['year'],
            usages=product.properties['usage'],
            descriptions=product.properties['description'],
            averageRatings=product.properties['averageRating'],
            numberOfRatings=product.properties['numberOfRatings'],
            # Prices=product.properties['Price'],
            imagePath=product.properties['imagePath']
        ))
    return response

@app.get("/images/{image_name}")
async def get_image(image_name: str):
    file_path = f"images/{image_name}.jpg"
    return FileResponse(file_path)




@app.get('/')
def getting():
    return "Hello world"





