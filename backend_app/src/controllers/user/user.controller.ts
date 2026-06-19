import { Request, Response } from "express";
import {
  getAllUsers,
  getUserById,
  createUser,
  updateUser,
  deleteUser,
} from "../../services/user/user.service";
import { BadRequest } from "../../errors";
import { SuccessResponse } from "../../utils/Response";

/**
 * Controller to fetch all users (with search and pagination)
 */
export const getAllUsersController = async (req: Request, res: Response) => {
  const page = req.query.page ? Number(req.query.page) : 1;
  const pageSize = req.query.pageSize ? Number(req.query.pageSize) : 10;
  const query = req.query.query as string | undefined;

  const result = await getAllUsers({ page, pageSize, query });
  SuccessResponse(res, result, 200);
};

/**
 * Controller to fetch a single user by ID
 */
export const getUserByIdController = async (req: Request, res: Response) => {
  const { id } = req.params;
  if (!id) {
    throw new BadRequest("User ID is required");
  }

  const result = await getUserById(id as string);
  SuccessResponse(res, result, 200);
};

/**
 * Controller to create a new user
 */
export const createUserController = async (req: Request, res: Response) => {
  const { email, password, name } = req.body;
  if (!email || !password || !name) {
    throw new BadRequest("Email, password, and name are required");
  }

  const result = await createUser(req.body);
  SuccessResponse(res, result, 201);
};

/**
 * Controller to update an existing user
 */
export const updateUserController = async (req: Request, res: Response) => {
  const { id } = req.params;
  if (!id) {
    throw new BadRequest("User ID is required");
  }

  const result = await updateUser(id as string, req.body);
  SuccessResponse(res, result, 200);
};

/**
 * Controller to delete a user and their associated data
 */
export const deleteUserController = async (req: Request, res: Response) => {
  const { id } = req.params;
  if (!id) {
    throw new BadRequest("User ID is required");
  }

  const result = await deleteUser(id as string);
  SuccessResponse(res, result, 200);
};
