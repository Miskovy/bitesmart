import axios from "axios";
import { aiBaseurl, aiApiKey, aiApiSecret } from "../../constants/api.constants";
import CryptoJS from "crypto-js";


const buildAuthHeaders = (method: string, path: string, data?: any) => {
    const timestamp = Date.now().toString();
    const rawBody   = data ? JSON.stringify(data).trim() : "";
    const bodyHash  = CryptoJS.SHA256(rawBody).toString();
    const payload   = `${timestamp}:${method.toUpperCase()}:${path}:${bodyHash}`;

    return {
        "X-Api-Key"   : aiApiKey,
        "X-Timestamp" : timestamp,
        "X-Signature" : CryptoJS.HmacSHA256(payload, aiApiSecret).toString(),
    };
};

export const aiApiRequest = async (prefix: string, method: string, data?: any) => {
    const response = await axios.request({
        url    : `${aiBaseurl}/${prefix}`,
        method,
        data,
        headers: buildAuthHeaders(method, `/${prefix}`, data),
    });

    return response.data;
};

export const apiRequest = async (url: string, method: string, data: any) => {
    const response = await axios.request({
        url,
        method,
        data,
    });
    return response.data;
};

