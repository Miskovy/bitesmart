import { BadRequest } from '../../errors';
import { aiApiRequest } from '../api/apiRequest.service';

export const sendPredictionRequestAR = async (file: Blob | File, food_width_cm: number, userId?: string) => {
    const formData = new FormData();
    formData.append('file', file, 'image.jpg');
    formData.append('food_width_cm', String(food_width_cm));

    if (userId) {
        formData.append('user_id', userId);
    }
    return await aiApiRequest('v4/predictAR', 'POST', formData);
};
export const sendPredictionRequestCallibration = async (file: Blob | File, plate_diameter_cm: number, userId?: string) => {
    const formData = new FormData();
    formData.append('file', file, 'image.jpg');
    formData.append('plate_diameter_cm', String(plate_diameter_cm));

    if (userId) {
        formData.append('user_id', userId);
    }
    return await aiApiRequest('v4/predict', 'POST', formData);
};


export const submitCorrection = async (trainingDataId: string, user_correction: string) => {
    if (!trainingDataId || !user_correction) {
        throw new BadRequest("Missing required fields: trainingDataId, user_correction");
    }
    return await aiApiRequest(`v4/correct/${trainingDataId}`, 'PUT', { user_correction });
};