import pool from "../db/config.js";

// Obtiene lista de nombres de productos.
export const getNameProducts = async (req, res) => {
  try {
    const result = await pool.query("SELECT * FROM products ORDER BY product_id ASC");
    return res.status(200).json({
      success: true,
      data: result.rows,
      count: result.rowCount,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Error al obtener los productos",
      error: error.message,
    });
  }
};

// Obtiene lista de stock de productos.
export const getStockProducts = async (req, res) => {
  try {
    const result = await pool.query("SELECT product_name, stock FROM products ORDER BY product_id ASC");
    return res.status(200).json({
      success: true,
      data: result.rows,
      count: result.rowCount,
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Error al obtener el stock de los productos",
      error: error.message,
    });
  }
};
