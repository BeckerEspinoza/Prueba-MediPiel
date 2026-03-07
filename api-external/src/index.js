import express from "express";
import dotenv from "dotenv";
import productsRoutes from "./routes/products.js";
dotenv.config();

const app = express();
app.use(express.json());
const PORT = parseInt(process.env.APP_PORT) || 3000;

app.get("/", (req, res) => {
  res.send("HELLO WORLD!");
});

//RUTAS
app.use("/products", productsRoutes);

app.listen(PORT, () => {
  console.log(`El servidor está corriendo en el puerto ${PORT}`);
});
