import { Router } from "express";
import { sendPredictionRequestAR, sendPredictionRequestCallibration , submitCorrection } from "../../controllers/food/prediction.controller";
import catchAsync from "../../utils/catchAsync";
import multer from "multer";


const router = Router();
const upload = multer();

router.post("/ar", upload.single("file"), catchAsync(sendPredictionRequestAR));
router.post("/callibration", upload.single("file"), catchAsync(sendPredictionRequestCallibration));
router.put("/correct/:trainingDataId", catchAsync(submitCorrection));
export default router;