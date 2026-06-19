import { Router } from "express";
import {
   getAllFoodController,
   getFoodByIdController,
   createCustomFoodController,
   getAllFoodDbController,
   getFoodDbByIdController,
   createFoodController,
   updateFoodController,
   deleteFoodController,
} from "../../controllers/food/food.controller";
import catchAsync from "../../utils/catchAsync";
import { authenticated } from "../../middlewares/Authenticated";
import { isAdmin } from "../../middlewares/isAdmin";

const router = Router();

// Public / general user endpoints
router.get("/", catchAsync(getAllFoodController));
router.post("/custom", authenticated, catchAsync(createCustomFoodController));

/* ==========================================
   ADMINISTRATIVE LOCAL DB CRUD ENDPOINTS
   ========================================== */

// Route to get all local database foods (needs to be above /:id to avoid matching conflict)
router.get("/db", authenticated, catchAsync(isAdmin), catchAsync(getAllFoodDbController));

// Route to get a specific local database food by ID (needs to be above /:id to avoid matching conflict)
router.get("/db/:id", authenticated, catchAsync(isAdmin), catchAsync(getFoodDbByIdController));

// Administrative create food
router.post("/", authenticated, catchAsync(isAdmin), catchAsync(createFoodController));

// Administrative update food
router.put("/:id", authenticated, catchAsync(isAdmin), catchAsync(updateFoodController));

// Administrative delete food
router.delete("/:id", authenticated, catchAsync(isAdmin), catchAsync(deleteFoodController));

/* ==========================================
   PUBLIC/USER GET BY ID ENDPOINT
   ========================================== */
router.get("/:id", catchAsync(getFoodByIdController));

export default router;
