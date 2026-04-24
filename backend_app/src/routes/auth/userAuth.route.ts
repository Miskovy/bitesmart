import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { userLogin } from "../../controllers/auth/userAuth.controller";
const router = Router();

router.post("/", catchAsync(userLogin));


export default router;