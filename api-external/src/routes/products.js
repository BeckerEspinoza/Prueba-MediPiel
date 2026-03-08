import express from "express";
import { getNameProducts, getStockProducts } from "../controllers/productsController.js";
const router = express.Router();

// GET /products
router.get("/", getNameProducts);

//GET /products/stock
router.get("/stock", getStockProducts);

export default router;
