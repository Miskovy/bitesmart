import sys
from pathlib import Path
from sqlalchemy_utils import database_exists, create_database

# Ensure the script can find your 'app' module from the project root
sys.path.append(str(Path(__file__).resolve().parent.parent.parent))
from dotenv import load_dotenv

# Manually load .env from the project root
env_path = Path(__file__).resolve().parent.parent.parent / ".env"
load_dotenv(dotenv_path=env_path)

from app.db.database import engine, SessionLocal, Base, SQLALCHEMY_DATABASE_URL
# Pre-import all models so SQLAlchemy metadata is aware of all relationships
import app.models.user_model
import app.models.subscription_model
import app.models.food_model
import app.models.meal_plan_model
import app.models.gamification_model
import app.models.chat_model
from app.models.food_model import FoodItem

# Real nutritional data per 100g and estimated densities/heights for all 119 classes
REAL_FOOD_DATA = {
    "Apple Pie": {"height": 3.0, "density": 0.90, "pro": 2.0, "carbs": 34.0, "fat": 11.0, "cals": 237},
    "Baby Back Ribs": {"height": 4.0, "density": 0.85, "pro": 20.0, "carbs": 5.0, "fat": 20.0, "cals": 277},
    "Baklava": {"height": 2.5, "density": 1.10, "pro": 5.0, "carbs": 40.0, "fat": 25.0, "cals": 400},
    "Beef Carpaccio": {"height": 0.5, "density": 1.05, "pro": 21.0, "carbs": 1.0, "fat": 15.0, "cals": 220},
    "Beef Tartare": {"height": 3.0, "density": 1.05, "pro": 20.0, "carbs": 2.0, "fat": 12.0, "cals": 200},
    "Beet Salad": {"height": 4.0, "density": 0.60, "pro": 2.0, "carbs": 10.0, "fat": 5.0, "cals": 90},
    "Beignets": {"height": 4.0, "density": 0.40, "pro": 4.0, "carbs": 40.0, "fat": 15.0, "cals": 310},
    "Bibimbap": {"height": 5.0, "density": 0.85, "pro": 8.0, "carbs": 25.0, "fat": 5.0, "cals": 170},
    "Bread Pudding": {"height": 4.0, "density": 0.95, "pro": 5.0, "carbs": 30.0, "fat": 12.0, "cals": 250},
    "Breakfast Burrito": {"height": 4.5, "density": 0.80, "pro": 12.0, "carbs": 22.0, "fat": 11.0, "cals": 230},
    "Bruschetta": {"height": 2.0, "density": 0.65, "pro": 3.0, "carbs": 18.0, "fat": 8.0, "cals": 150},
    "Caesar Salad": {"height": 6.0, "density": 0.25, "pro": 4.0, "carbs": 8.0, "fat": 12.0, "cals": 150},
    "Cannoli": {"height": 3.0, "density": 0.75, "pro": 6.0, "carbs": 30.0, "fat": 12.0, "cals": 250},
    "Caprese Salad": {"height": 3.0, "density": 0.80, "pro": 10.0, "carbs": 3.0, "fat": 15.0, "cals": 180},
    "Carrot Cake": {"height": 5.0, "density": 0.85, "pro": 4.0, "carbs": 45.0, "fat": 20.0, "cals": 380},
    "Ceviche": {"height": 3.0, "density": 1.00, "pro": 15.0, "carbs": 5.0, "fat": 2.0, "cals": 100},
    "Cheese Plate": {"height": 2.0, "density": 1.05, "pro": 20.0, "carbs": 2.0, "fat": 28.0, "cals": 340},
    "Cheesecake": {"height": 4.0, "density": 1.05, "pro": 6.0, "carbs": 25.0, "fat": 22.0, "cals": 321},
    "Chicken Curry": {"height": 4.5, "density": 1.05, "pro": 12.0, "carbs": 8.0, "fat": 10.0, "cals": 170},
    "Chicken Quesadilla": {"height": 1.5, "density": 0.85, "pro": 15.0, "carbs": 22.0, "fat": 14.0, "cals": 260},
    "Chicken Wings": {"height": 3.0, "density": 0.80, "pro": 15.0, "carbs": 0.0, "fat": 19.0, "cals": 230},
    "Chocolate Cake": {"height": 4.5, "density": 0.85, "pro": 4.0, "carbs": 53.0, "fat": 16.0, "cals": 371},
    "Chocolate Mousse": {"height": 4.0, "density": 0.70, "pro": 4.0, "carbs": 20.0, "fat": 15.0, "cals": 225},
    "Churros": {"height": 2.5, "density": 0.60, "pro": 4.0, "carbs": 40.0, "fat": 18.0, "cals": 340},
    "Clam Chowder": {"height": 5.0, "density": 1.02, "pro": 4.0, "carbs": 10.0, "fat": 5.0, "cals": 100},
    "Club Sandwich": {"height": 5.0, "density": 0.50, "pro": 14.0, "carbs": 22.0, "fat": 11.0, "cals": 240},
    "Crab Cakes": {"height": 2.5, "density": 0.90, "pro": 15.0, "carbs": 10.0, "fat": 12.0, "cals": 210},
    "Creme Brulee": {"height": 2.0, "density": 1.05, "pro": 4.0, "carbs": 20.0, "fat": 25.0, "cals": 320},
    "Croque Madame": {"height": 4.0, "density": 0.75, "pro": 14.0, "carbs": 18.0, "fat": 16.0, "cals": 270},
    "Cup Cakes": {"height": 6.0, "density": 0.65, "pro": 3.0, "carbs": 50.0, "fat": 15.0, "cals": 350},
    "Deviled Eggs": {"height": 2.5, "density": 1.00, "pro": 10.0, "carbs": 2.0, "fat": 16.0, "cals": 190},
    "Donuts": {"height": 3.5, "density": 0.45, "pro": 4.0, "carbs": 45.0, "fat": 20.0, "cals": 380},
    "Dumplings": {"height": 2.5, "density": 0.95, "pro": 8.0, "carbs": 20.0, "fat": 5.0, "cals": 160},
    "Edamame": {"height": 3.0, "density": 0.75, "pro": 11.0, "carbs": 10.0, "fat": 5.0, "cals": 120},
    "Eggs Benedict": {"height": 5.0, "density": 0.85, "pro": 12.0, "carbs": 15.0, "fat": 18.0, "cals": 270},
    "Escargots": {"height": 2.0, "density": 1.05, "pro": 16.0, "carbs": 2.0, "fat": 8.0, "cals": 140},
    "Falafel": {"height": 3.0, "density": 0.85, "pro": 13.0, "carbs": 31.0, "fat": 17.0, "cals": 330},
    "Fava Beans": {"height": 3.0, "density": 0.95, "pro": 8.0, "carbs": 20.0, "fat": 1.0, "cals": 110},
    "Filet Mignon": {"height": 3.5, "density": 1.05, "pro": 26.0, "carbs": 0.0, "fat": 15.0, "cals": 250},
    "Fish And Chips": {"height": 4.0, "density": 0.70, "pro": 10.0, "carbs": 20.0, "fat": 12.0, "cals": 230},
    "Foie Gras": {"height": 2.0, "density": 1.05, "pro": 11.0, "carbs": 4.0, "fat": 43.0, "cals": 450},
    "French Fries": {"height": 4.0, "density": 0.50, "pro": 3.4, "carbs": 41.0, "fat": 15.0, "cals": 312},
    "French Onion Soup": {"height": 5.0, "density": 1.00, "pro": 4.0, "carbs": 8.0, "fat": 5.0, "cals": 95},
    "French Toast": {"height": 2.5, "density": 0.65, "pro": 7.0, "carbs": 25.0, "fat": 11.0, "cals": 230},
    "Fried Calamari": {"height": 3.0, "density": 0.75, "pro": 15.0, "carbs": 15.0, "fat": 10.0, "cals": 210},
    "Fried Rice": {"height": 4.0, "density": 0.85, "pro": 5.0, "carbs": 30.0, "fat": 6.0, "cals": 190},
    "Frozen Yogurt": {"height": 6.0, "density": 0.75, "pro": 4.0, "carbs": 22.0, "fat": 2.0, "cals": 120},
    "Garlic Bread": {"height": 2.5, "density": 0.40, "pro": 8.0, "carbs": 40.0, "fat": 16.0, "cals": 350},
    "Gnocchi": {"height": 3.0, "density": 1.05, "pro": 4.0, "carbs": 35.0, "fat": 2.0, "cals": 170},
    "Greek Salad": {"height": 5.0, "density": 0.45, "pro": 3.0, "carbs": 5.0, "fat": 10.0, "cals": 110},
    "Grilled Cheese Sandwich": {"height": 2.0, "density": 0.60, "pro": 12.0, "carbs": 28.0, "fat": 18.0, "cals": 320},
    "Grilled Salmon": {"height": 2.5, "density": 1.02, "pro": 20.0, "carbs": 0.0, "fat": 13.0, "cals": 208},
    "Guacamole": {"height": 3.0, "density": 0.95, "pro": 2.0, "carbs": 8.0, "fat": 14.0, "cals": 160},
    "Gyoza": {"height": 2.5, "density": 0.95, "pro": 8.0, "carbs": 20.0, "fat": 8.0, "cals": 180},
    "Hamburger": {"height": 5.0, "density": 0.65, "pro": 13.0, "carbs": 30.0, "fat": 14.0, "cals": 295},
    "Hot And Sour Soup": {"height": 5.0, "density": 1.00, "pro": 3.0, "carbs": 6.0, "fat": 2.0, "cals": 50},
    "Hot Dog": {"height": 4.0, "density": 0.70, "pro": 10.0, "carbs": 18.0, "fat": 15.0, "cals": 250},
    "Huevos Rancheros": {"height": 3.0, "density": 0.85, "pro": 8.0, "carbs": 15.0, "fat": 10.0, "cals": 180},
    "Hummus": {"height": 2.5, "density": 1.05, "pro": 8.0, "carbs": 14.0, "fat": 10.0, "cals": 170},
    "Ice Cream": {"height": 5.0, "density": 0.55, "pro": 3.5, "carbs": 24.0, "fat": 11.0, "cals": 207},
    "Kebab": {"height": 3.0, "density": 0.90, "pro": 18.0, "carbs": 5.0, "fat": 12.0, "cals": 200},
    "Kibbeh": {"height": 3.5, "density": 0.95, "pro": 12.0, "carbs": 20.0, "fat": 10.0, "cals": 220},
    "Koshari": {"height": 5.0, "density": 0.85, "pro": 6.0, "carbs": 35.0, "fat": 4.0, "cals": 190},
    "Kunafa": {"height": 2.5, "density": 0.95, "pro": 6.0, "carbs": 42.0, "fat": 15.0, "cals": 320},
    "Lasagna": {"height": 4.5, "density": 1.05, "pro": 10.0, "carbs": 15.0, "fat": 8.0, "cals": 170},
    "Lobster Bisque": {"height": 4.0, "density": 1.02, "pro": 5.0, "carbs": 6.0, "fat": 12.0, "cals": 150},
    "Lobster Roll Sandwich": {"height": 4.5, "density": 0.55, "pro": 12.0, "carbs": 20.0, "fat": 10.0, "cals": 220},
    "Macaroni And Cheese": {"height": 3.5, "density": 1.05, "pro": 6.0, "carbs": 20.0, "fat": 10.0, "cals": 190},
    "Macarons": {"height": 2.0, "density": 0.60, "pro": 4.0, "carbs": 60.0, "fat": 20.0, "cals": 420},
    "Mahashi": {"height": 4.0, "density": 0.90, "pro": 3.0, "carbs": 15.0, "fat": 5.0, "cals": 120},
    "Makmoura": {"height": 5.0, "density": 0.95, "pro": 10.0, "carbs": 25.0, "fat": 12.0, "cals": 250},
    "Mandi": {"height": 4.5, "density": 0.85, "pro": 12.0, "carbs": 28.0, "fat": 8.0, "cals": 230},
    "Mansaf": {"height": 4.5, "density": 0.90, "pro": 10.0, "carbs": 20.0, "fat": 10.0, "cals": 210},
    "Miso Soup": {"height": 5.0, "density": 1.00, "pro": 3.0, "carbs": 4.0, "fat": 1.0, "cals": 35},
    "Mojadra": {"height": 4.0, "density": 0.85, "pro": 8.0, "carbs": 25.0, "fat": 6.0, "cals": 180},
    "Muskhan": {"height": 3.0, "density": 0.80, "pro": 10.0, "carbs": 20.0, "fat": 15.0, "cals": 250},
    "Mussels": {"height": 3.0, "density": 0.60, "pro": 12.0, "carbs": 4.0, "fat": 2.0, "cals": 86},
    "Nachos": {"height": 4.0, "density": 0.40, "pro": 6.0, "carbs": 30.0, "fat": 16.0, "cals": 300},
    "Omelette": {"height": 1.5, "density": 0.95, "pro": 11.0, "carbs": 1.0, "fat": 12.0, "cals": 154},
    "Onion Rings": {"height": 3.5, "density": 0.35, "pro": 3.0, "carbs": 35.0, "fat": 20.0, "cals": 330},
    "Oysters": {"height": 1.5, "density": 1.00, "pro": 9.0, "carbs": 4.0, "fat": 2.0, "cals": 68},
    "Pad Thai": {"height": 4.0, "density": 0.85, "pro": 6.0, "carbs": 35.0, "fat": 10.0, "cals": 230},
    "Paella": {"height": 3.5, "density": 0.90, "pro": 10.0, "carbs": 22.0, "fat": 6.0, "cals": 180},
    "Pancakes": {"height": 2.0, "density": 0.60, "pro": 6.0, "carbs": 28.0, "fat": 10.0, "cals": 227},
    "Panna Cotta": {"height": 3.5, "density": 1.00, "pro": 3.0, "carbs": 18.0, "fat": 15.0, "cals": 220},
    "Pastries": {"height": 3.5, "density": 0.45, "pro": 5.0, "carbs": 40.0, "fat": 25.0, "cals": 400},
    "Peking Duck": {"height": 3.0, "density": 0.95, "pro": 18.0, "carbs": 2.0, "fat": 28.0, "cals": 330},
    "Pho": {"height": 6.0, "density": 1.00, "pro": 6.0, "carbs": 15.0, "fat": 2.0, "cals": 100},
    "Pizza": {"height": 1.5, "density": 0.80, "pro": 11.0, "carbs": 33.0, "fat": 10.0, "cals": 266},
    "Plate Of Meat": {"height": 2.5, "density": 1.05, "pro": 25.0, "carbs": 0.0, "fat": 15.0, "cals": 250},
    "Pork Chop": {"height": 2.5, "density": 1.05, "pro": 21.0, "carbs": 0.0, "fat": 14.0, "cals": 210},
    "Poutine": {"height": 4.5, "density": 0.85, "pro": 5.0, "carbs": 25.0, "fat": 15.0, "cals": 250},
    "Prime Rib": {"height": 3.5, "density": 1.05, "pro": 20.0, "carbs": 0.0, "fat": 25.0, "cals": 300},
    "Pulled Pork Sandwich": {"height": 5.0, "density": 0.65, "pro": 12.0, "carbs": 20.0, "fat": 12.0, "cals": 240},
    "Qatayef": {"height": 2.0, "density": 0.75, "pro": 4.0, "carbs": 35.0, "fat": 10.0, "cals": 250},
    "Ramen": {"height": 6.0, "density": 1.00, "pro": 5.0, "carbs": 12.0, "fat": 4.0, "cals": 100},
    "Ravioli": {"height": 2.5, "density": 1.00, "pro": 6.0, "carbs": 20.0, "fat": 8.0, "cals": 170},
    "Red Velvet Cake": {"height": 5.0, "density": 0.80, "pro": 4.0, "carbs": 50.0, "fat": 15.0, "cals": 350},
    "Rice With Milk": {"height": 3.0, "density": 1.05, "pro": 3.0, "carbs": 22.0, "fat": 2.0, "cals": 110},
    "Risotto": {"height": 3.0, "density": 1.05, "pro": 4.0, "carbs": 25.0, "fat": 8.0, "cals": 190},
    "Samosa": {"height": 3.0, "density": 0.70, "pro": 5.0, "carbs": 25.0, "fat": 12.0, "cals": 230},
    "Samosas": {"height": 3.0, "density": 0.70, "pro": 5.0, "carbs": 25.0, "fat": 12.0, "cals": 230},
    "Sashimi": {"height": 1.5, "density": 1.05, "pro": 20.0, "carbs": 0.0, "fat": 5.0, "cals": 130},
    "Scallops": {"height": 2.0, "density": 1.02, "pro": 12.0, "carbs": 3.0, "fat": 1.0, "cals": 70},
    "Seaweed Salad": {"height": 3.5, "density": 0.40, "pro": 2.0, "carbs": 8.0, "fat": 2.0, "cals": 50},
    "Shawarma": {"height": 4.0, "density": 0.80, "pro": 12.0, "carbs": 20.0, "fat": 10.0, "cals": 220},
    "Shishabark": {"height": 4.0, "density": 1.00, "pro": 8.0, "carbs": 15.0, "fat": 12.0, "cals": 200},
    "Shrimp And Grits": {"height": 4.0, "density": 0.95, "pro": 10.0, "carbs": 15.0, "fat": 8.0, "cals": 170},
    "Spaghetti Bolognese": {"height": 3.5, "density": 1.10, "pro": 12.0, "carbs": 30.0, "fat": 9.0, "cals": 250},
    "Spaghetti Carbonara": {"height": 3.5, "density": 1.10, "pro": 10.0, "carbs": 25.0, "fat": 15.0, "cals": 270},
    "Spring Rolls": {"height": 2.5, "density": 0.65, "pro": 3.0, "carbs": 20.0, "fat": 10.0, "cals": 180},
    "Steak": {"height": 2.0, "density": 1.05, "pro": 25.0, "carbs": 0.0, "fat": 19.0, "cals": 271},
    "Strawberry Shortcake": {"height": 5.0, "density": 0.60, "pro": 3.0, "carbs": 35.0, "fat": 12.0, "cals": 260},
    "Sushi": {"height": 2.5, "density": 1.05, "pro": 4.5, "carbs": 30.0, "fat": 0.5, "cals": 143},
    "Tacos": {"height": 4.0, "density": 0.70, "pro": 9.0, "carbs": 20.0, "fat": 10.0, "cals": 210},
    "Takoyaki": {"height": 3.0, "density": 0.80, "pro": 6.0, "carbs": 25.0, "fat": 10.0, "cals": 210},
    "Tiramisu": {"height": 4.0, "density": 0.85, "pro": 5.0, "carbs": 35.0, "fat": 15.0, "cals": 300},
    "Tuna Tartare": {"height": 3.0, "density": 1.05, "pro": 18.0, "carbs": 2.0, "fat": 8.0, "cals": 150},
    "Waffles": {"height": 2.0, "density": 0.55, "pro": 6.0, "carbs": 30.0, "fat": 12.0, "cals": 250}
}


def seed_database():
    print("Connecting to Bitesmart database...")
    
    if not database_exists(engine.url):
        print(f"Database not found. Creating database: {engine.url.database}...")
        create_database(engine.url)
        
    print("Ensuring all database tables exist...")
    Base.metadata.create_all(bind=engine)

    txt_path = Path(__file__).resolve().parent.parent.parent / "storage" / "data" / "food_119_classes.txt"
    db = SessionLocal()

    try:
        with open(txt_path, "r") as f:
            classes = [line.strip() for line in f.readlines() if line.strip()]

        for class_name in classes:
            existing_item = db.query(FoodItem).filter(FoodItem.class_name == class_name).first()
            if existing_item:
                continue

            # Fallback in case a key is accidentally missed, though all 119 are covered
            data = REAL_FOOD_DATA.get(class_name, {
                "height": 2.0, "density": 1.0, "pro": 0.0, "carbs": 0.0, "fat": 0.0, "cals": 0.0
            })

            new_food = FoodItem(
                class_name=class_name,
                avg_height_cm=data["height"],
                density_g_cm3=data["density"],
                protein_per_100g=data["pro"],
                carbs_per_100g=data["carbs"],
                fats_per_100g=data["fat"],
                cals_per_100g=data["cals"]
            )
            db.add(new_food)

        db.commit()
        print(f"Successfully seeded {len(classes)} classes with real data into bitesmartDB!")

    except Exception as e:
        db.rollback()
        print(f"Error seeding database: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_database()