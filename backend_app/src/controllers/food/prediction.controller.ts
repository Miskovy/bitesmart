import { Request , Response } from "express";
import { BadRequest } from "../../errors";
import { SuccessResponse } from "../../utils/Response";
import * as predictionService from "../../services/food/prediction.service";



export const sendPredictionRequestAR = async (req: Request, res: Response) => {
    const user_id = req.user?.id;
    const food_width_cm = req.body?.food_width_cm;

    const file = req.file;

    if(!file || !food_width_cm) {
        throw new BadRequest("Missing required fields: file, food_width_cm");
    }

    const food_width = Number(food_width_cm);

    try {
        const fileBlob = new Blob([new Uint8Array(file.buffer)], { type: file.mimetype });
        const result = await predictionService.sendPredictionRequestAR(fileBlob, food_width, user_id);
        return SuccessResponse(res, result);
    } catch (error) {
        throw new BadRequest(`Failed to send prediction request: ${error instanceof Error ? error.message : String(error)}`);
    }
};

export const sendPredictionRequestCallibration = async (req: Request, res: Response) => {
    const user_id = req.user?.id;
    const plate_diameter_cm = req.body?.plate_diameter_cm;
    const file = req.file;

    if(!file || !plate_diameter_cm) {
        throw new BadRequest("Missing required fields: file, plate_diameter_cm");
    }

    const plate_diameter = Number(plate_diameter_cm);

    try {
        const fileBlob = new Blob([new Uint8Array(file.buffer)], { type: file.mimetype });
        const result = await predictionService.sendPredictionRequestCallibration(fileBlob, plate_diameter, user_id);
        return SuccessResponse(res, result);
    } catch (error) {
        throw new BadRequest(`Failed to send prediction request: ${error instanceof Error ? error.message : String(error)}`);
    }
};

export const submitCorrection = async (req: Request, res: Response) => {
    const {trainingDataId} = req.params;
    const user_correction = req.body.user_correction;
    
    try {
        const result = await predictionService.submitCorrection(trainingDataId as string, user_correction);
        return SuccessResponse(res, result);
    } catch (error) {
        throw new BadRequest(`Failed to submit correction: ${error instanceof Error ? error.message : String(error)}`);
    }
};