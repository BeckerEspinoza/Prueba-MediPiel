import express from "express";
import { getOrder, ordersSummary, storeOrder, updateOrderStatus } from "../controllers/ordersController.js";
const router = express.Router();

//GET /orders/summary
router.get("/summary", ordersSummary);
//GET /orders/:order_id
router.get("/:order_id", getOrder);

//POST /orders
router.post("/", storeOrder);

//PATCH /orders/:order_id
router.patch("/:order_id", updateOrderStatus);

export default router;
