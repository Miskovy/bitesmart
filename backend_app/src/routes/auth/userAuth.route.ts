import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { userLogin } from "../../controllers/auth/userAuth.controller";
import { signup } from "../../controllers/auth/userAuth.controller";

const router = Router();

router.post("/", catchAsync(userLogin));
router.post("/", catchAsync(signup));

export default router;