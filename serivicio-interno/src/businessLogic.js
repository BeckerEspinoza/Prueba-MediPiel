export const validateStock = (orderItems, stock) => {
  const insufficientItems = [];

  for (const item of orderItems) {
    const product = stock.find((p) => p.product_id === item.product_id);

    if (!product || product.stock < item.quantity) {
      insufficientItems.push({
        product_id: item.product_id,
        product_name: product?.product_name ?? "Desconocido",
        requested: item.quantity,
        available: product?.stock ?? 0,
      });
    }
  }

  return {
    isValid: insufficientItems.length === 0,
    insufficientItems,
  };
};
