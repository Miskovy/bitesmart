import { Router } from "express";
import { getAllFoodController, getFoodByIdController } from "../../controllers/food/food.controller";
import catchAsync from "../../utils/catchAsync";
const router = Router();

router.get("/", catchAsync(getAllFoodController));
router.get("/:id", catchAsync(getFoodByIdController));


export default router;
