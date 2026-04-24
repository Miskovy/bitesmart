import { Request, Response } from "express";
import { getAllFood, getFoodById } from "../../services/food/food.service";
import { SuccessResponse } from "../../utils/Response";
import { BadRequest } from "../../errors";

export const getAllFoodController = async (req: Request, res: Response) => {
    const { page, limit, search } = req.query;
    const food = await getAllFood({
        page:   page   ? Number(page)   : undefined,
        limit:  limit  ? Number(limit)  : undefined,
        search: search as string,
    });
    return SuccessResponse(res, food, 200);
};

export const getFoodByIdController = async (req: Request, res: Response) => {
    const { id } = req.params;
    if (!id) {
        throw new BadRequest("Id is required");
    }
    const food = await getFoodById(id as string);
    return SuccessResponse(res, food, 200);
};

