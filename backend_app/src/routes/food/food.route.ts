import { Router } from "express";
import { getAllFoodController, getFoodByIdController, createCustomFoodController } from "../../controllers/food/food.controller";
import catchAsync from "../../utils/catchAsync";
import { authenticated } from "../../middlewares/Authenticated";

const router = Router();

router.get("/", catchAsync(getAllFoodController));

//! Created by Antigravity: Route to create a custom food (needs to be above /:id to avoid matching issues)
router.post("/custom", authenticated, catchAsync(createCustomFoodController));

router.get("/:id", catchAsync(getFoodByIdController));


export default router;
