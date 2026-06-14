import { Request, Response } from "express";
import { BadRequest } from "../../errors";
import { SuccessResponse } from "../../utils/Response";
import * as predictionService from "../../services/food/prediction.service";



export const sendPredictionRequestAR = async (req: Request, res: Response) => {
    const user_id = req.user?.id;
    const food_width_cm = req.body?.food_width_cm;
    const file = req.file;

    if(!file || !food_width_cm) {
        const missing = [];
        if (!file) missing.push("file");
        if (!food_width_cm) missing.push("food_width_cm");
        const bodyKeys = req.body ? Object.keys(req.body) : [];
        throw new BadRequest(
            `Missing required fields: ${missing.join(", ")}. ` +
            `Received body keys: [${bodyKeys.join(", ")}], ` +
            `file field name: ${file ? `'${file.fieldname}'` : "none"}, ` +
            `Content-Type: '${req.headers["content-type"]}'`
        );
    }

    const food_width = Number(food_width_cm);

    try {
        const fileBlob = new Blob([new Uint8Array(file.buffer)], { type: file.mimetype });
        const result = await predictionService.sendPredictionRequestAR(fileBlob, food_width, user_id);
        return SuccessResponse(res, result);
    } catch (error: any) {
        console.error("Prediction Request AR Error:", error);
        const errorMsg = error instanceof Error ? error.message : String(error);
        const responseData = error?.response?.data;
        const responseDataStr = responseData ? (typeof responseData === "object" ? JSON.stringify(responseData) : String(responseData)) : "";
        throw new BadRequest(`Failed to send prediction request: ${errorMsg}${responseDataStr ? `. AI Response: ${responseDataStr}` : ""}`);
    }
};

export const sendPredictionRequestCallibration = async (req: Request, res: Response) => {
    const user_id = req.user?.id;
    const plate_diameter_cm = req.body?.plate_diameter_cm;
    const file = req.file;

    if(!file || !plate_diameter_cm) {
        const missing = [];
        if (!file) missing.push("file");
        if (!plate_diameter_cm) missing.push("plate_diameter_cm");
        const bodyKeys = req.body ? Object.keys(req.body) : [];
        throw new BadRequest(
            `Missing required fields: ${missing.join(", ")}. ` +
            `Received body keys: [${bodyKeys.join(", ")}], ` +
            `file field name: ${file ? `'${file.fieldname}'` : "none"}, ` +
            `Content-Type: '${req.headers["content-type"]}'`
        );
    }

    const plate_diameter = Number(plate_diameter_cm);

    try {
        const fileBlob = new Blob([new Uint8Array(file.buffer)], { type: file.mimetype });
        const result = await predictionService.sendPredictionRequestCallibration(fileBlob, plate_diameter, user_id);
        return SuccessResponse(res, result);
    } catch (error: any) {
        console.error("Prediction Request Calibration Error:", error);
        const errorMsg = error instanceof Error ? error.message : String(error);
        const responseData = error?.response?.data;
        const responseDataStr = responseData ? (typeof responseData === "object" ? JSON.stringify(responseData) : String(responseData)) : "";
        throw new BadRequest(`Failed to send prediction request: ${errorMsg}${responseDataStr ? `. AI Response: ${responseDataStr}` : ""}`);
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