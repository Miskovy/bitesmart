import { aiApiRequest , apiRequest } from "../api/apiRequest.service";
import { aiBaseurl } from "../../constants/api.constants";

export const getAllFood = async (params: {
    page?:   number;
    limit?:  number;
    search?: string;
}) => {
    const query = new URLSearchParams();
    if (params.page)   query.append("page",   params.page.toString());
    if (params.limit)  query.append("limit",  params.limit.toString());
    if (params.search) query.append("search", params.search);

    const queryString = query.size ? `?${query.toString()}` : "";
    return apiRequest(`${aiBaseurl}/food/${queryString}`, "GET", {});
};

export const getFoodById = async (id: string) => {
    const response = await apiRequest(`${aiBaseurl}/food/${id}`, "GET", {});
    return response;
};
