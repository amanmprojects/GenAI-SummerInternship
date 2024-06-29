from fastapi import FastAPI, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from pydantic import BaseModel
from typing import List
from dotenv import load_dotenv
import search
import prompt_templates
load_dotenv()


# cors origins
# cors origins
origins = [
    "http://localhost",
    "http://localhost:3000",
    "http://localhost:8888",
]


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class QueryRequest(BaseModel):
    query: str


import os
from fastapi import UploadFile
GROQ_API_KEY = os.getenv("GROQ_API_KEY")

groqHandler = search.groqHandler(api_key=GROQ_API_KEY, template=prompt_templates.message_to_product6)
wqs = search.WeaviateQueryService(collection="CleanedProducts", groqHandler=groqHandler, target_vector="name_master_sub_art_col_use_seas_gender")
image_search = search.ImageSearch(wqs = wqs)

@app.get("/")
async def read_root():
    return '<h1> Welcome to the Semantic Search Engine </h1><br> <h2> Please use the <a href="http://localhost:8888/search/">/search/</a> endpoint to search for products </h2>'

@app.post("/text_search/")
async def search_item(query: QueryRequest, top_n: int = 10, groq_simplify: bool = True):
    query = query.query
    limit = top_n
    print(f" \n\n\n Got query : {query}\n\n\n")

    # Perform search
    response = wqs.get_results(query=query, limit=limit, groq_llama_simplfy=groq_simplify, print_responses_name=True)
    return response

@app.post("/image-search/")
async def search_image(image: UploadFile = File(...), top_n: int = 10, groq_simplify: bool = True):
    # Process the image
    image_data = await image.read()
    
    response = image_search.get_results(image_data=image_data, top_n=top_n)
    
    return response
    # return response




