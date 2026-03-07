import pool from "../db/config.js";

export const getProducts = async (req, res) => {
  try {
    const products = await pool.query("select * from products");
    return res.status(200).json(products.rows);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
};
