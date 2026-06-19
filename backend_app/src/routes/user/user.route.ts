import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import {
  getAllUsersController,
  getUserByIdController,
  createUserController,
  updateUserController,
  deleteUserController,
} from "../../controllers/user/user.controller";
import { isAdmin } from "../../middlewares/isAdmin";

const router = Router();

// Protect all user CRUD endpoints with admin validation
router.use(catchAsync(isAdmin));

router.get("/", catchAsync(getAllUsersController));
router.get("/:id", catchAsync(getUserByIdController));
router.post("/", catchAsync(createUserController));
router.put("/:id", catchAsync(updateUserController));
router.delete("/:id", catchAsync(deleteUserController));

export default router;
