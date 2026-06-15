import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import {
    getChallengesController,
    joinChallengeController,
    leaveChallengeController,
    updateChallengeProgressController,
    createChallengeController
} from "../../controllers/user/challenge.controller";
import { isAdmin } from "../../middlewares/isAdmin";

const router = Router();

router.get("/", catchAsync(getChallengesController));
router.post("/", catchAsync(isAdmin), catchAsync(createChallengeController));
router.post("/:challengeId/join", catchAsync(joinChallengeController));
router.post("/:challengeId/leave", catchAsync(leaveChallengeController));
router.post("/:challengeId/progress", catchAsync(updateChallengeProgressController));

export default router;
