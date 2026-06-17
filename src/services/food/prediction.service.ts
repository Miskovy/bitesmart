import { db } from '../../db/connection';
import { BadRequest } from '../../errors';
import { aiApiRequest } from '../api/apiRequest.service';
import { eq } from 'drizzle-orm';
import { foodItems } from '../../models/food_items';

export const sendPredictionRequestAR = async (file: Blob | File, food_width_cm: number, userId?: string) => {
    const formData = new FormData();
    formData.append('file', file, 'image.jpg');
    formData.append('food_width_cm', String(food_width_cm));

    if (userId) {
        formData.append('user_id', userId);
    }
    const result = await aiApiRequest('v4/predictAR', 'POST', formData);
    
    const foodDetected = result?.data?.food_detected;
    if (foodDetected) {
        const food_item = await db.select().from(foodItems).where(eq(foodItems.class_name, foodDetected)).limit(1);
        if (food_item.length > 0) {
            result.data.food_item_id = food_item[0].id;
        }
    }
    
    return result;
};
export const sendPredictionRequestCallibration = async (file: Blob | File, plate_diameter_cm: number, userId?: string) => {
    const formData = new FormData();
    formData.append('file', file, 'image.jpg');
    formData.append('plate_diameter_cm', String(plate_diameter_cm));

    if (userId) {
        formData.append('user_id', userId);
    }
    const result = await aiApiRequest('v4/predict', 'POST', formData);
    
    const foodDetected = result?.data?.food_detected;
    if (foodDetected) {
        const food_item = await db.select().from(foodItems).where(eq(foodItems.class_name, foodDetected)).limit(1);
        if (food_item.length > 0) {
            result.data.food_item_id = food_item[0].id;
        }
    }
    
    return result;
};


export const submitCorrection = async (trainingDataId: string, user_correction: string) => {
    if (!trainingDataId || !user_correction) {
        throw new BadRequest("Missing required fields: trainingDataId, user_correction");
    }
    return await aiApiRequest(`v4/correct/${trainingDataId}`, 'PUT', { user_correction });
};