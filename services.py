from typing import List, Dict, Any
from sentence_transformers import SentenceTransformer # type: ignore
import weaviate # type: ignore
import weaviate.classes as wvc # type: ignore
import warnings
from dotenv import load_dotenv
from groq import Groq # type: ignore
import os
from prompt_template import *
import argparse

# Suppressing warning
warnings.filterwarnings("ignore", category=FutureWarning, message=".*resume_download.*")
load_dotenv()


MODEL_DICT = {
    'mini-6' : "all-MiniLM-L6-v2",
    "mini-12" : 'all-MiniLM-L12-v2',
    'paraphrase-6' : "paraphrase-MiniLM-L6-v2",
    'paraphrase-12' : "paraphrase-MiniLM-L12-v2",
}
# Handling arguments for python Scripts

MODEL_NAME = MODEL_DICT['paraphrase-6']
# def main(arg1):
#     print(f'Model: {arg1}')
#     MODEL_NAME = MODEL_DICT[args.model]

# if __name__ == "__main__":
#     parser = argparse.ArgumentParser(description="Script for creating a weaviate Database from CSV")
#     parser.add_argument('--model', type=str, default='paraphrase-6', help='Set the Vectorizer Model from the given : '.join(MODEL_DICT.keys()).join(MODEL_DICT.values()))
#     args = parser.parse_args()
#     main(args.model, args.col, args.csv)



model = SentenceTransformer(MODEL_NAME)







class WeaviateQueryService:
    def __init__(self, collection:str):
        self.model = model
        self.client = weaviate.connect_to_local()
        self.collection = self.client.collections.get(collection)
        self.groqHandler = groqHandler()

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
    def __init__(self) -> None:
        self.api_key = os.environ.get('GROQ_API_KEY')
        self.groq_client = Groq(api_key=self.api_key)
    
    def query_simplify(self, query:str):
            response = self.groq_client.chat.completions.create(
                messages=[
                    {
                        "role": "system",
                        'content': message_to_product2
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
        





    
    