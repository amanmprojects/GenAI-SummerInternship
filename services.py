from typing import List, Dict, Any
from sentence_transformers import SentenceTransformer
import weaviate
import weaviate.classes as wvc
import warnings

# Suppressing warning
warnings.filterwarnings("ignore", category=FutureWarning, message=".*resume_download.*")



# Setting the model
MODEL_LIST = ["sentence-transformers/paraphrase-multilingual-MiniLM-L12-v2", "paraphrase-MiniLM-L6-v2", "all-MiniLM-L6-v2", "paraphrase-MiniLM-L12-v2"]
MODEL_NAME = MODEL_LIST[1]

model = SentenceTransformer(MODEL_NAME)


# init weaviate client
client = weaviate.connect_to_local()

print("Hello world")


class WeaviateQueryService:
    def __init__(self, collection:str):
        self.model = model
        self.collection = client.collections.get(collection)

    def get_results(self, query: str, top_n: int, print_responses_name:bool = False) -> List[Dict[str, Any]]:
        # Vectorizing the query
        query_vector = self.model.encode(query, convert_to_tensor=True).tolist()

        # Retrieving the Top n results
        responses = self.collection.query.near_vector(
            near_vector=query_vector,
            limit=top_n,
            return_metadata=wvc.query.MetadataQuery(certainty=True)
        ).objects

        if print_responses_name:
            for response in responses:
                print(response.properties)

        
        return responses





    
    