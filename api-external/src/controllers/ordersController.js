import pool from "../db/config.js";

// Crea una nueva orden y espera un cuerpo
// {
//   customer_id: ?,
//   items: [{
//     product_id: ?,
//     quantity: ?
//   }]
// }
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
    return res.status(500).json({
      success: false,
      message: "Hubo un error.",
      error: error.message,
    });
  } finally {
    trx.release();
  }
};

// Obtiene una orden por su ID
export const getOrder = async (req, res) => {
  const { order_id } = req.params;
  try {
    const orderResult = await pool.query(
      `SELECT o.*, oi.product_id, oi.quantity, oi.unit_price
      FROM orders o
      INNER JOIN order_items oi
      on o.order_id = oi.order_id
      WHERE o.order_id = $1`,
      [order_id],
    );

    if (orderResult.rowCount === 0) {
      return res.status(404).json({ success: false, message: "Orden no encontrada." });
    }

    const orderData = {
      order_id: orderResult.rows[0].order_id,
      customer_id: orderResult.rows[0].customer_id,
      status: orderResult.rows[0].status,
      total_amount: orderResult.rows[0].total_amount,
      created_at: orderResult.rows[0].created_at,
      items: orderResult.rows.map((row) => ({
        product_id: row.product_id,
        quantity: row.quantity,
        unit_price: row.unit_price,
      })),
    };

    return res.json({ success: true, data: orderData });
  } catch (error) {
    return res.status(500).json({ success: false, message: "Hubo un error", error: error.message });
  }
};

// Actualiza el estatus de una orden
export const updateOrderStatus = async (req, res) => {
  const { order_id } = req.params;
  const { status } = req.body;

  const validStatus = ["pending", "confirmed", "rejected"];
  if (!validStatus.includes(status)) {
    return res.status(400).json({
      success: false,
      message: "El estado no es válido. Use: pending, confirmed, rejected.",
    });
  }

  try {
    const result = await pool.query("UPDATE orders SET status = $1 WHERE order_id = $2 RETURNING order_id, status", [
      status,
      order_id,
    ]);
    if (result.rowCount === 0) {
      return res.status(404).json({
        success: false,
        message: "Orden no encontrada.",
      });
    }

    return res.status(200).json({
      success: true,
      message: `Orden actualizada a ${status}.`,
      data: result.rows[0],
    });
  } catch (error) {
    return res.status(500).json({
      success: false,
      message: "Hubo un error.",
      error: error.message,
    });
  }
};
