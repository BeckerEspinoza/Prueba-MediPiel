import express from "express";
import { storeOrder } from "../controllers/ordersController.js";
const router = express.Router();

//POST /orders
router.post("/", storeOrder);

export default router;
