import os
import json
import urllib.request
import urllib.error

PROJECT_ID = os.environ.get("FIREBASE_PROJECT_ID", "nuance-e-commerce")
API_KEY = os.environ.get("FIREBASE_API_KEY", "")
BASE_URL = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents"

CATEGORIES = [
    {"id": "cat_all", "name": "All", "itemCount": 8},
    {"id": "cat_outerwear", "name": "Outerwear", "itemCount": 3},
    {"id": "cat_tailored", "name": "Tailored Suits", "itemCount": 2},
    {"id": "cat_linen", "name": "Linen & Resort", "itemCount": 2},
    {"id": "cat_knitwear", "name": "Knitwear", "itemCount": 2},
    {"id": "cat_accessories", "name": "Bags & Acc", "itemCount": 2},
]

PRODUCTS = [
    {
        "id": "prod_001",
        "name": "Nuance Editorial Double-Breasted Suit",
        "brand": "NUANCE",
        "category": "Tailored Suits",
        "description": "Handcrafted from Italian virgin wool blend with structured shoulders, wide lapels, and fluid wide-leg pleated trousers. Designed for effortless modern tailoring.",
        "price": 340.0,
        "originalPrice": 420.0,
        "images": [
            "assets/images/hero_banner.jpg",
            "https://images.unsplash.com/photo-1594938298603-c8148c4dae35?auto=format&fit=crop&w=1000&q=80"
        ],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "colors": [
            {"name": "Sandstone Beige", "colorValue": 0xFFD8C7B5},
            {"name": "Slate Charcoal", "colorValue": 0xFF4A5568},
            {"name": "Obsidian Black", "colorValue": 0xFF1A1A1A}
        ],
        "rating": 4.9,
        "reviewsCount": 84,
        "isFeatured": True,
        "isNew": True,
        "inStock": True
    },
    {
        "id": "prod_002",
        "name": "Oversized Washed Linen Two-Piece",
        "brand": "NUANCE",
        "category": "Linen & Resort",
        "description": "Crafted from 100% Normandy flax linen. Features relaxed dropped-shoulder button-down shirt paired with tailored high-rise pleated bermuda shorts with leather accent belt.",
        "price": 185.0,
        "originalPrice": 220.0,
        "images": [
            "assets/images/summer_linen.jpg",
            "https://images.unsplash.com/photo-1515886657613-9f3515b0c78f?auto=format&fit=crop&w=1000&q=80"
        ],
        "sizes": ["XS", "S", "M", "L"],
        "colors": [
            {"name": "Oatmeal Natural", "colorValue": 0xFFE3DAC9},
            {"name": "Olive Sage", "colorValue": 0xFF708238},
            {"name": "Crisp White", "colorValue": 0xFFFFFFFF}
        ],
        "rating": 4.8,
        "reviewsCount": 62,
        "isFeatured": True,
        "isNew": True,
        "inStock": True
    },
    {
        "id": "prod_003",
        "name": "Architectural Minimalist Wool Overcoat",
        "brand": "NUANCE",
        "category": "Outerwear",
        "description": "A timeless Scandinavian silhouette cut in heavyweight melton wool. Seamless concealed placket, deep slant pockets, and full cupro interior lining.",
        "price": 490.0,
        "originalPrice": 580.0,
        "images": [
            "assets/images/wool_coat.jpg",
            "https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&w=1000&q=80"
        ],
        "sizes": ["S", "M", "L", "XL"],
        "colors": [
            {"name": "Midnight Black", "colorValue": 0xFF121214},
            {"name": "Camel Tan", "colorValue": 0xFFC19A6B}
        ],
        "rating": 5.0,
        "reviewsCount": 112,
        "isFeatured": True,
        "isNew": False,
        "inStock": True
    },
    {
        "id": "prod_004",
        "name": "Cashmere Ribbed Mockneck Sweater",
        "brand": "NUANCE",
        "category": "Knitwear",
        "description": "Spun from 100% Grade-A Mongolian cashmere with featherweight softness and substantial gauge. Designed for layering under tailored coats or relaxed weekend wearing.",
        "price": 210.0,
        "originalPrice": 260.0,
        "images": [
            "https://images.unsplash.com/photo-1576566588028-4147f3842f27?auto=format&fit=crop&w=1000&q=80",
            "https://images.unsplash.com/photo-1583743814966-8936f5b7be1a?auto=format&fit=crop&w=1000&q=80"
        ],
        "sizes": ["S", "M", "L", "XL"],
        "colors": [
            {"name": "Ivory Cream", "colorValue": 0xFFFDFBF7},
            {"name": "Heather Ash", "colorValue": 0xFF9E9E9E},
            {"name": "Espresso", "colorValue": 0xFF3D2314}
        ],
        "rating": 4.7,
        "reviewsCount": 39,
        "isFeatured": False,
        "isNew": True,
        "inStock": True
    },
    {
        "id": "prod_005",
        "name": "Structured Leather Atelier Tote",
        "brand": "NUANCE",
        "category": "Bags & Acc",
        "description": "Sculptural full-grain calfskin tote with microfiber suede interior, magnetic closure, and removable zip pouch. Accommodates a 15-inch laptop with room to spare.",
        "price": 295.0,
        "originalPrice": 350.0,
        "images": [
            "https://images.unsplash.com/photo-1548036328-c9fa89d128fa?auto=format&fit=crop&w=1000&q=80",
            "https://images.unsplash.com/photo-1584917865442-de89df76afd3?auto=format&fit=crop&w=1000&q=80"
        ],
        "sizes": ["One Size"],
        "colors": [
            {"name": "Cognac Saddle", "colorValue": 0xFF8B4513},
            {"name": "Matte Noir", "colorValue": 0xFF1A1A1A}
        ],
        "rating": 4.9,
        "reviewsCount": 75,
        "isFeatured": True,
        "isNew": False,
        "inStock": True
    },
    {
        "id": "prod_006",
        "name": "Fluid Silk Satin Slip Maxi Dress",
        "brand": "NUANCE",
        "category": "Tailored Suits",
        "description": "Bias-cut 22mm heavyweight mulberry silk that skims the silhouette effortlessly. Adjustable delicate straps, soft cowl neckline, and subtle floor sweep.",
        "price": 275.0,
        "originalPrice": 320.0,
        "images": [
            "https://images.unsplash.com/photo-1595777457583-95e059d581b8?auto=format&fit=crop&w=1000&q=80",
            "https://images.unsplash.com/photo-1566174053879-31528523f8ae?auto=format&fit=crop&w=1000&q=80"
        ],
        "sizes": ["XS", "S", "M", "L"],
        "colors": [
            {"name": "Champagne Gold", "colorValue": 0xFFF3E5AB},
            {"name": "Emerald Moss", "colorValue": 0xFF2E4C38},
            {"name": "Noir", "colorValue": 0xFF141414}
        ],
        "rating": 4.8,
        "reviewsCount": 51,
        "isFeatured": False,
        "isNew": True,
        "inStock": True
    },
    {
        "id": "prod_007",
        "name": "Technical Water-Repellent Trench",
        "brand": "NUANCE",
        "category": "Outerwear",
        "description": "Modernized British trench coat tailored in recycled Japanese technical twill. Storm flap, horn buttons, belted waist, and deep storm collar.",
        "price": 430.0,
        "originalPrice": 430.0,
        "images": [
            "https://images.unsplash.com/photo-1539571696357-5a69c17a67c6?auto=format&fit=crop&w=1000&q=80"
        ],
        "sizes": ["XS", "S", "M", "L", "XL"],
        "colors": [
            {"name": "Stone Beige", "colorValue": 0xFFD2B48C},
            {"name": "Forest Olive", "colorValue": 0xFF354A3B}
        ],
        "rating": 4.6,
        "reviewsCount": 28,
        "isFeatured": False,
        "isNew": False,
        "inStock": True
    },
    {
        "id": "prod_008",
        "name": "Relaxed Tailored Pleated Trousers",
        "brand": "NUANCE",
        "category": "Tailored Suits",
        "description": "High-waisted double-pleated dress trousers cut with a relaxed straight leg. Premium wool-lyocell blend provides gentle drape and wrinkle resistance.",
        "price": 165.0,
        "originalPrice": 195.0,
        "images": [
            "https://images.unsplash.com/photo-1624378439575-d8705ad7ae80?auto=format&fit=crop&w=1000&q=80"
        ],
        "sizes": ["28", "30", "32", "34", "36"],
        "colors": [
            {"name": "Dark Grey Melange", "colorValue": 0xFF4F5359},
            {"name": "Warm Taupe", "colorValue": 0xFF8B8589},
            {"name": "Black", "colorValue": 0xFF111111}
        ],
        "rating": 4.9,
        "reviewsCount": 93,
        "isFeatured": True,
        "isNew": False,
        "inStock": True
    }
]

def py_to_firestore(val):
    if val is None:
        return {"nullValue": None}
    elif isinstance(val, bool):
        return {"booleanValue": val}
    elif isinstance(val, int):
        return {"integerValue": str(val)}
    elif isinstance(val, float):
        return {"doubleValue": val}
    elif isinstance(val, str):
        return {"stringValue": val}
    elif isinstance(val, list):
        return {"arrayValue": {"values": [py_to_firestore(x) for x in val]}}
    elif isinstance(val, dict):
        return {"mapValue": {"fields": {k: py_to_firestore(v) for k, v in val.items()}}}
    return {"stringValue": str(val)}

def upload_doc(collection, doc_id, data):
    url = f"{BASE_URL}/{collection}/{doc_id}?key={API_KEY}"
    fields = {k: py_to_firestore(v) for k, v in data.items() if k != "id"}
    body = json.dumps({"fields": fields}).encode("utf-8")
    
    req = urllib.request.Request(url, data=body, headers={"Content-Type": "application/json"}, method="PATCH")
    try:
        with urllib.request.urlopen(req) as resp:
            print(f" [OK] {collection}/{doc_id}")
            return True
    except urllib.error.HTTPError as e:
        err_msg = e.read().decode("utf-8")
        print(f" [FAIL] {collection}/{doc_id}: HTTP {e.code} - {err_msg}")
        return False

def main():
    if not API_KEY:
        print("Error: FIREBASE_API_KEY environment variable is required.")
        print("Usage: FIREBASE_API_KEY=\"<your-api-key>\" python3 seed_firestore.py")
        return

    print(f"Connecting to Cloud Firestore: {PROJECT_ID}...")
    success_count = 0
    fail_count = 0

    print("\n--- Seeding Categories ---")
    for cat in CATEGORIES:
        if upload_doc("categories", cat["id"], cat):
            success_count += 1
        else:
            fail_count += 1

    print("\n--- Seeding Products ---")
    for prod in PRODUCTS:
        if upload_doc("products", prod["id"], prod):
            success_count += 1
        else:
            fail_count += 1

    print(f"\nCompleted: {success_count} succeeded, {fail_count} failed.")

if __name__ == "__main__":
    main()
