import pool from "../db/config.js";

//
export const storeOrder = async (req, res) => {
  const { customer_id, items } = req.body;

  if (!Array.isArray(items) || items.length === 0) {
    return res.status(400).json({ success: false, message: "La orden debe tener al menos 1 producto." });
  }

  const trx = await pool.connect();
  try {
    await trx.query("BEGIN");

    let totalAmount = 0;
    const itemsWithPrices = [];

    for (const item of items) {
      const productResult = await trx.query("SELECT price FROM products WHERE product_id = $1", [item.product_id]);

      if (productResult.rowCount === 0) {
        throw new Error(`Producto ${item.product_id} no existe.`);
      }

      const price = parseFloat(productResult.rows[0].price);
      totalAmount += price * item.quantity;
      itemsWithPrices.push({ ...item, unit_price: price });
    }

    const orderRes = await trx.query(
      "INSERT INTO orders (customer_id, total_amount) VALUES ($1, $2) RETURNING order_id",
      [customer_id, totalAmount],
    );
    const newOrderId = orderRes.rows[0].order_id;
    for (const item of itemsWithPrices) {
      await trx.query("INSERT INTO order_items (order_id, product_id, quantity, unit_price) VALUES ($1, $2, $3, $4)", [
        newOrderId,
        item.product_id,
        item.quantity,
        item.unit_price,
      ]);
    }

    await trx.query("COMMIT");

    res.status(201).json({
      success: true,
      order_id: newOrderId,
      message: "Orden creada exitosamente",
    });
  } catch (error) {
    await trx.query("ROLLBACK");
    return res.status(400).json({
      success: false,
      error: error.message,
    });
  } finally {
    trx.release();
  }
};
