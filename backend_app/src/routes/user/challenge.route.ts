import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import { 
    getChallengesController, 
    joinChallengeController, 
    leaveChallengeController, 
    updateChallengeProgressController 
} from "../../controllers/user/challenge.controller";

const router = Router();

//! Created by Antigravity: Routes for community challenges
router.get("/", catchAsync(getChallengesController));
router.post("/:challengeId/join", catchAsync(joinChallengeController));
router.post("/:challengeId/leave", catchAsync(leaveChallengeController));
router.post("/:challengeId/progress", catchAsync(updateChallengeProgressController));

export default router;
