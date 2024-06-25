import numpy as np
from transformers import CLIPProcessor, CLIPModel
from PIL import Image
import requests
import pandas as pd
import time
# from uniquegetter import unique_getter

# Load the model and processor
model = CLIPModel.from_pretrained("openai/clip-vit-base-patch32")
processor = CLIPProcessor.from_pretrained("openai/clip-vit-base-patch32")



# # get the top 500 descriptions from styles.csv
# df = pd.read_csv('./styles.csv', on_bad_lines='skip')['productDisplayName'].head(100).to_list()
# print("reading csv succeed")


while True:
    name = input("Put URL of IMage? (Press ENTER)")
    image = Image.open(name)
    start_time = time.time()
    # List of candidate descriptions
    candidate_texts = ["Women", "Men"]

    # candidate_texts = unique_getter()[:10]

    # candidate_texts = pd.read_csv('amazon.csv')['product_name'][:10].to_list()
    # print(candidate_texts, type(candidate_texts))

    # Encode the text and image

    inputs = processor(text=candidate_texts, images=image, return_tensors="pt", padding=True)
    outputs = model(**inputs)

    # Logits corresponding to the similarity between the text and the image
    logits_per_image = outputs.logits_per_image
    probs = logits_per_image.softmax(dim=1)  # Softmax to get probabilities

    # Find the most probable description
    max_prob_index = np.argmax(probs.detach().numpy())
    score = probs[0][max_prob_index]
    description = candidate_texts[max_prob_index]

    # Print the most likely description
    print(f"The image is likely: {description} with score : {score}")
    end_time = time.time()
    print(f"total time needed = {end_time - start_time}s")
