import streamlit as st
import torch
import clip
from PIL import Image

# Load the model
device = "cuda" if torch.cuda.is_available() else "cpu"
model, preprocess = clip.load("ViT-B/32", device=device)

# Define the six lists of possible descriptions
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

lists = [item, item1, item2, color, brand, gender]

st.title("Image to Text Description using CLIP")

uploaded_file = st.file_uploader("Choose an image...", type=["jpg", "jpeg", "png"])

if uploaded_file is not None:
    image = Image.open(uploaded_file)

    st.image(image, caption="Uploaded Image", use_column_width=True)
    st.write("")

    # Preprocess the image
    image_input = preprocess(image).unsqueeze(0).to(device)

    best_descriptions = []

    for text_descriptions in lists:
        # Tokenize the text descriptions
        text_inputs = clip.tokenize(text_descriptions).to(device)

        # Calculate feature vectors
        with torch.no_grad():
            image_features = model.encode_image(image_input)
            text_features = model.encode_text(text_inputs)

        # Normalize the feature vectors
        image_features /= image_features.norm(dim=-1, keepdim=True)
        text_features /= text_features.norm(dim=-1, keepdim=True)

        # Calculate the similarity between the image and each description
        similarity = (image_features @ text_features.T).squeeze(0)

        # Get the most similar description
        best_description_index = similarity.argmax().item()
        best_description = text_descriptions[best_description_index]
        best_descriptions.append(best_description)

    # Create the final description string
    final_description = f"I want {best_descriptions[5]} {best_descriptions[0]} {best_descriptions[1]} {best_descriptions[2]} of color {best_descriptions[3]} by {best_descriptions[4]}"
    
    # Display the final description
    st.write(final_description)