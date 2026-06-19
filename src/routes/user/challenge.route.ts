import { Router } from "express";
import catchAsync from "../../utils/catchAsync";
import {
    getChallengesController,
    joinChallengeController,
    leaveChallengeController,
    updateChallengeProgressController,
    createChallengeController,
    getAllChallengesAdminController,
    getChallengeByIdAdminController,
    updateChallengeController,
    deleteChallengeController,
} from "../../controllers/user/challenge.controller";
import { isAdmin } from "../../middlewares/isAdmin";

const router = Router();

/* ==========================================
   ADMINISTRATIVE CHALLENGES CRUD ENDPOINTS
   ========================================== */

// Admin list all challenges (must be above wildcard user paths to avoid conflict)
router.get("/admin", catchAsync(isAdmin), catchAsync(getAllChallengesAdminController));

// Admin get specific challenge by ID
router.get("/admin/:id", catchAsync(isAdmin), catchAsync(getChallengeByIdAdminController));

// Admin create challenge
router.post("/admin", catchAsync(isAdmin), catchAsync(createChallengeController));

// Admin update challenge
router.put("/admin/:id", catchAsync(isAdmin), catchAsync(updateChallengeController));

// Admin delete challenge
router.delete("/admin/:id", catchAsync(isAdmin), catchAsync(deleteChallengeController));

/* ==========================================
   USER ENDPOINTS
   ========================================== */

router.get("/", catchAsync(getChallengesController));
router.post("/", catchAsync(isAdmin), catchAsync(createChallengeController)); // Legacy/alternative route
router.post("/:challengeId/join", catchAsync(joinChallengeController));
router.post("/:challengeId/leave", catchAsync(leaveChallengeController));
router.post("/:challengeId/progress", catchAsync(updateChallengeProgressController));

export default router;
