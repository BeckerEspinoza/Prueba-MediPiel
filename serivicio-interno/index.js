import { processOrder } from "./src/processor.js";

const orderId = process.argv[2];

if (!orderId) {
  console.error("[ERROR] Debes proporcionar un order_id.");
  process.exit(1);
}

processOrder(Number(orderId))
  .then(() => process.exit(0))
  .catch(() => process.exit(1));
