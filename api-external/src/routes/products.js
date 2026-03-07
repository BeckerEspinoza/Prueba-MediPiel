import express from "express";
import { getProducts } from "../controllers/productsController.js";
const router = express.Router();

// GET /products
router.get("/", getProducts);

export default router;
