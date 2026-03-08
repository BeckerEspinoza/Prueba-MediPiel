import axios from "axios";
import dotenv from "dotenv";

dotenv.config();

const api = axios.create({
  baseURL: process.env.API_URL,
});

export const getOrder = async (orderId) => {
  const { data } = await api.get(`/orders/${orderId}`);
  console.log("[DEBUG] Orden recibida:", JSON.stringify(data, null, 2));
  return data.data;
};

export const getStock = async () => {
  const { data } = await api.get("/products/stock");
  return data.data;
};

export const updateOrderStatus = async (orderId, status) => {
  const { data } = await api.patch(`/orders/${orderId}`, { status });
  return data.data;
};
