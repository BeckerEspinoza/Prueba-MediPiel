import pool from "./db/config.js";
import { getOrder, getStock, updateOrderStatus } from "./apiClient.js";
import { validateStock } from "./businessLogic.js";

export const processOrder = async (orderId) => {
  console.log(`[INFO] Iniciando procesamiento de orden #${orderId}`);

  const order = await getOrder(orderId);
  console.log(`[INFO] Orden #${orderId} obtenida - Status actual: ${order.status}`);

  if (order.status !== "pending") {
    console.log(`[WARN] Orden #${orderId} no está pendiente, se omite el procesamiento`);
    return;
  }

  const stock = await getStock();
  const { isValid, insufficientItems } = validateStock(order.items, stock);

  const trx = await pool.connect();

  try {
    await trx.query("BEGIN");

    if (isValid) {
      for (const item of order.items) {
        await trx.query(
          `INSERT INTO inventory_movements (product_id, order_id, quantity, movement_type)
           VALUES ($1, $2, $3, 'sale')`,
          [item.product_id, orderId, item.quantity],
        );

        await trx.query(`UPDATE products SET stock = stock - $1 WHERE product_id = $2`, [
          item.quantity,
          item.product_id,
        ]);
      }

      await trx.query("COMMIT");
      console.log(`[INFO] Movimientos de inventario registrados para orden #${orderId}`);
      await updateOrderStatus(orderId, "confirmed");
      console.log(`[SUCCESS] Orden #${orderId} confirmada`);
    } else {
      await trx.query("ROLLBACK");
      console.log(`[WARN] Stock insuficiente para orden #${orderId}:`);
      insufficientItems.forEach((item) => {
        console.log(`  - ${item.product_name}: solicitado ${item.requested}, disponible ${item.available}`);
      });
      await updateOrderStatus(orderId, "rejected");
      console.log(`[INFO] Orden #${orderId} rechazada`);
    }
  } catch (error) {
    await trx.query("ROLLBACK");
    console.error(`[ERROR] Error procesando orden #${orderId}:`, error.message);
    throw error;
  } finally {
    trx.release();
  }
};
