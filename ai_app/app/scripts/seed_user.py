import bcrypt
from sqlalchemy.orm import Session
from app.db.database import SessionLocal, engine, Base
from app.models.user_model import User, UserTarget, UserMedicalConditions, Genders, Goals
from app.models.food_model import DailyLogs, FoodItem

def seed_test_user():
    print("Generating MySQL database tables...")
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()
    try:
        test_email = "test@bitesmart.com"
        existing_user = db.query(User).filter(User.email == test_email).first()

        if existing_user:
            print(f"Test user already exists! User ID: {existing_user.id}")
            return existing_user.id

        print("Creating new test user...")

        hashed_pw = bcrypt.hashpw(b"password123", bcrypt.gensalt()).decode("utf-8")

        new_user = User(
            name="Miskovy",
            password=hashed_pw,
            email=test_email,
            gender=Genders.Male,
            age=23,
            userGoal=Goals.WeightLoss
        )
        db.add(new_user)
        db.commit()
        db.refresh(new_user)

        new_targets = UserTarget(
            userId=new_user.id,
            calTotal=1800,
            proteins=160,
            carbs=150,
            fats=60
        )
        db.add(new_targets)

        new_medical = UserMedicalConditions(
            userId=new_user.id,
            isAnemia=True,  # The AI should recommend Iron
            isHypertension=True  # The AI should warn against high sodium
        )
        db.add(new_medical)

        db.commit()
        print("✅ Database successfully seeded!")
        print(f"🎯 YOUR POSTMAN USER ID IS: {new_user.id}")

        return new_user.id

    except Exception as e:
        db.rollback()
        print(f"❌ Seeding failed: {e}")
    finally:
        db.close()


if __name__ == "__main__":
    seed_test_user()