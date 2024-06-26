from typing import List, Dict, Any
from sentence_transformers import SentenceTransformer # type: ignore
import weaviate # type: ignore
import weaviate.classes as wvc # type: ignore
import warnings
from dotenv import load_dotenv
from groq import Groq # type: ignore
import os
from prompt_template import message_to_product


# Suppressing warning
warnings.filterwarnings("ignore", category=FutureWarning, message=".*resume_download.*")

load_dotenv()


# Setting the model
MODEL_LIST = ["sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2", "paraphrase-MiniLM-L6-v2", "all-MiniLM-L6-v2", "paraphrase-MiniLM-L12-v2"]
MODEL_NAME = 'all-MiniLM-L12-v2'

model = SentenceTransformer(MODEL_NAME)


# init weaviate client



GROQ_API_KEY = os.environ.get("GROQ_API_KEY")


class WeaviateQueryService:
    def __init__(self, collection:str):
        self.model = model
        self.client = weaviate.connect_to_local()
        self.collection = self.client.collections.get(collection)
        self.groqHandler = groqHandler(api_key=GROQ_API_KEY)

    def get_results(self, query: str, top_n: int,groq_llama_simplfy :  bool = True ,print_responses_name:bool = False) -> List[Dict[str, Any]]:
        
        if groq_llama_simplfy:
            query_mod = self.groqHandler.query_simplify(query=query)
        else: query_mod = query
    



        # Vectorizing the query
        query_vector = self.model.encode(query_mod, convert_to_tensor=True).tolist()

        # Retrieving the Top n results
        responses = self.collection.query.near_vector(
            near_vector=query_vector,
            limit=top_n,
            return_metadata=wvc.query.MetadataQuery(certainty=True)
        ).objects

        if print_responses_name:
            for response in responses:
                print(response.properties['productDisplayName'])

        
        return responses
    
class groqHandler:
    def __init__(self, api_key) -> None:
        self.api_key = api_key
        self.GROQ_API_KEY = os.environ.get("GROQ_API_KEY")
        self.groq_client = Groq(api_key=self.api_key)
    
    def query_simplify(self, query:str):
            response = self.groq_client.chat.completions.create(
                messages=[
                    {
                        "role": "system",
                        'content': message_to_product
                    },
                    {
                        "role": "user",
                        "content": query,
                    },
                ],
                model="llama3-8b-8192",
                )
            print(response.choices[0].message.content)
            return str(response.choices[0].message.content)
        





    
    