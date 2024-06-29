import weaviate
from weaviate.classes.query import MetadataQuery
from typing import List, Dict, Any
import os
from groq import Groq
import prompt_templates
from pydantic import BaseModel
import torch
import clip
from PIL import Image
import io



class groqHandler:
    def __init__(self, api_key:(str), template:str = prompt_templates.message_to_product5):
        self.api_key = api_key
        try:
            self.groq_client = Groq(api_key=self.api_key)
        except Exception as e:
            print(f"Error: {e}")
        finally:
            print("Groq client initialized")
        self.template = template
        self.messages = [
            {
                "role": "system",
                "content": self.template
            }
        ]

    
    def query_to_products(self, query:str) -> str:
            
            self.messages.append(
                {
                    "role": "user",
                    "content": query
                }
            )
            chat_completion = self.groq_client.chat.completions.create(
                messages=self.messages,
                model="llama3-8b-8192"
            )
            self.messages.append(
                {
                    "role": "assistant",
                    "content": chat_completion.choices[0].message.content
                }
            )
            print(chat_completion.choices[0].message.content)
            return chat_completion.choices[0].message.content







class WeaviateQueryService:
    def __init__(self, collection:str = "CleanedProducts", groqHandler : groqHandler = None, target_vector:str = None):

        try:
            self.client = weaviate.connect_to_local()
        except Exception as e:
            print(f"Error: {e}")
        finally:
            if(self.client.is_ready()):
                print("Weaviate client initialized")
            else:
                print("Weaviate client not initialized")

        
        self.collection = self.client.collections.get(collection)
        self.groqHandler = groqHandler


        if target_vector:
            self.target_vector = target_vector
        else:
            self.target_vector = "name_master_sub_art_col_use_seas_gender"

        

    def get_results(self, query: str, limit: int = 10, groq_llama_simplfy : bool = True , print_responses_name: bool = False) -> List[Dict[str, Any]]:
        
        if groq_llama_simplfy and self.groqHandler:
            modified_query = self.groqHandler.query_to_products(query)
        else: 
            modified_query = query

        results = self.collection.query.near_text(
            # concepts=modified_query.split(','),
            query=modified_query,
            limit=limit,
            # distance=0.7,
            return_metadata=MetadataQuery(distance=True),
            target_vector=self.target_vector
        )


        list_of_results = list()
        if print_responses_name:
            # print(results.objects)
            for o in results.objects:
                print(o.properties["productDisplayName"],  o.metadata.distance)
                list_of_results.append(o.properties)


        return list_of_results
        # return results.objects.properties


class ImageSearch:
    def __init__(self, wqs: WeaviateQueryService):
        self.device = 'cuda' if torch.cuda.is_available() else 'cpu'
        model, preprocess = clip.load("ViT-B/32", device=self.device)
        self.model=model
        self.preprocess=preprocess
        self.wqs = wqs
        item1 = ['Topwear', 'Bottomwear', 'Watches', 'Socks', 'Shoes', 'Belts', 'Flip Flops', 'Bags', 'Innerwear', 'Sandal',
         'Shoe Accessories', 'Fragrance', 'Jewellery', 'Lips', 'Saree', 'Eyewear', 'Nails', 'Scarves', 'Dress',
         'Loungewear and Nightwear', 'Wallets', 'Apparel Set', 'Headwear', 'Mufflers', 'Skin Care', 'Makeup',
         'Free Gifts', 'Ties', 'Accessories', 'Skin', 'Beauty Accessories', 'Water Bottle', 'Eyes', 'Bath and Body',
         'Gloves', 'Sports Accessories', 'Sports Equipment', 'Stoles', 'Cufflinks', 'Hair', 'Perfumes',
         'Home Furnishing', 'Umbrellas', 'Wristbands']
        item2 = ['Shirts', 'Jeans', 'Watches', 'Track Pants', 'Tshirts', 'Socks', 'Casual Shoes', 'Belts', 'Flip Flops',
         'Handbags', 'Tops', 'Bra', 'Sandals', 'Shoe Accessories', 'Sweatshirts', 'Deodorant', 'Formal Shoes',
         'Bracelet', 'Lipstick', 'Flats', 'Kurtas', 'Waistcoat', 'Sports Shoes', 'Shorts', 'Briefs', 'Sarees',
         'Perfume and Body Mist', 'Heels', 'Sunglasses', 'Innerwear Vests', 'Pendant', 'Nail Polish', 'Laptop Bag',
         'Scarves', 'Rain Jacket', 'Dresses', 'Night suits', 'Skirts', 'Wallets', 'Blazers', 'Ring', 'Kurta Sets',
         'Clutches', 'Shrug', 'Backpacks', 'Caps', 'Trousers', 'Earrings', 'Camisoles', 'Boxers', 'Jewellery Set',
         'Dupatta', 'Capris', 'Lip Gloss', 'Bath Robe', 'Mufflers', 'Tunics', 'Jackets', 'Trunk', 'Lounge Pants',
         'Face Wash and Cleanser', 'Necklace and Chains', 'Duffel Bag', 'Sports Sandals', 'Foundation and Primer',
         'Sweaters', 'Free Gifts', 'Trolley Bag', 'Tracksuits', 'Swimwear', 'Shoe Laces', 'Fragrance Gift Set',
         'Bangle', 'Nightdress', 'Ties', 'Baby Dolls', 'Leggings', 'Highlighter and Blush', 'Travel Accessory',
         'Kurtis', 'Mobile Pouch', 'Messenger Bag', 'Lip Care', 'Face Moisturisers', 'Compact', 'Eye Cream',
         'Accessory Gift Set', 'Beauty Accessory', 'Jumpsuit', 'Kajal and Eyeliner', 'Water Bottle', 'Suspenders',
         'Lip Liner', 'Robe', 'Salwar and Dupatta', 'Patiala', 'Stockings', 'Eyeshadow', 'Headband', 'Tights',
         'Nail Essentials', 'Churidar', 'Lounge Tshirts', 'Face Scrub and Exfoliator', 'Lounge Shorts', 'Gloves',
         'Mask and Peel', 'Wristbands', 'Tablet Sleeve', 'Footballs', 'Stoles', 'Shapewear', 'Nehru Jackets',
         'Salwar', 'Cufflinks', 'Jeggings', 'Hair Colour', 'Concealer', 'Rompers', 'Body Lotion', 'Sunscreen',
         'Booties', 'Waist Pouch', 'Hair Accessory', 'Rucksacks', 'Basketballs', 'Lehenga Choli', 'Clothing Set',
         'Mascara', 'Toner', 'Cushion Covers', 'Key chain', 'Makeup Remover', 'Lip Plumper', 'Umbrellas',
         'Face Serum and Gel', 'Hat', 'Mens Grooming Kit', 'Rain Trousers', 'Body Wash and Scrub', 'Suits']
        color = ['Navy Blue', 'Blue', 'Silver', 'Black', 'Grey', 'Green', 'Purple', 'White', 'Beige', 'Brown', 'Bronze',
         'Teal', 'Copper', 'Pink', 'Off White', 'Maroon', 'Red', 'Khaki', 'Orange', 'Coffee Brown', 'Yellow',
         'Charcoal', 'Gold', 'Steel', 'Tan', 'Multi', 'Magenta', 'Lavender', 'Sea Green', 'Cream', 'Peach', 'Olive',
         'Skin', 'Burgundy', 'Grey Melange', 'Rust', 'Rose', 'Lime Green', 'Mauve', 'Turquoise Blue', 'Metallic',
         'Mustard', 'Taupe', 'Nude', 'Mushroom Brown', 'Unknown', 'Fluorescent Green']
        item = ['Casual', 'Ethnic', 'Formal', 'Sports', 'Unknown', 'Smart Casual', 'Travel', 'Party', 'Home']
        brand = ['Dior', 'Versace', 'Ugg', 'Puma', "Levi's", 'Nike', 'Dolce & Gabbana', 'Vans', 'Skechers', 
         'Converse', 'Citizen', 'Calvin Klein', 'Swarovski', 'Tommy Hilfiger', 'Timberland', 'Aldo', 
         'Armani', 'Hugo Boss', 'Zara', 'Adidas', 'Oakley', 'Guess', 'Reebok', 'Ralph Lauren', 
         'Clarks', 'Crocs', 'Fossil', 'Burberry', 'ASICS', 'Bata', 'Valentino', 'Salomon', 
         'New Balance', 'Ray-Ban', 'Casio', 'Unknown']
        gender = ['Men', 'Women', 'Unisex']
        self.lists = [color, brand, item, item1, item2, gender]

    def get_results(self, image_data, top_n: int = 10):

        image = Image.open(io.BytesIO(image_data))


        # Preprocess the image
        image_input = self.preprocess(image).unsqueeze(0).to(self.device)
        best_descriptions = []

        for text_descriptions in self.lists:
            # Tokenize the text
            text_input = clip.tokenize(text_descriptions).to(self.device)

            # Calculate features
            with torch.no_grad():
                image_features = self.model.encode_image(image_input)
                text_features = self.model.encode_text(text_input)
                logits_per_image, logits_per_text = self.model(image_input, text_input)
                probs = logits_per_image.softmax(dim=1).cpu().numpy()

                best_descriptions.append(text_descriptions[probs.argmax()])

        final_description = " ".join(best_descriptions)
        print(f"Final description: {final_description}")

        # Perform search
        response = self.wqs.get_results(query=final_description, limit=top_n, groq_llama_simplfy=True, print_responses_name=True)

        return response




    

