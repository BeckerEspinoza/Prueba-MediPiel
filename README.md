# Prueba-MediPiel

## Instalación de dependencias

Usa el manejador de paquetes de NPM para instalar dependencias

```
npm install
```

## Inicializar el Servidor

Usa el script para levantar el servidor de la API

```
npm run dev
```

## Endpoints

### Obtener lista de productos

`GET /products`

Devuelve una lista de los productos existentes en la BD.

### Obtener lista del inventario

`GET /products/stock`

Devuelve una lista que muestra Nombre del producto y su Stock.

### Crear una Orden

`POST /orders`

Crea una Orden de compra procesando múltiples productos en una sola transacción atómica.
Calcula automáticamente el monto total basándose en los precios vigentes en la BD.

**Ejemplo del cuerpo que espera:**

```json
{
  "customer_id": 1,
  "items": [
    { "product_id": 1, "quantity": 2 },
    { "product_id": 3, "quantity": 1 }
  ]
}
```

### Consultar una Orden por Id

`GET /orders/:order_id`

Devuelve la información completa de una Orden específica, incluyendo los datos generales
y el listado detallado de productos adquiridos mediante un `INNER JOIN`.

### Actualizar el estado de Orden

`PATCH /orders/:order_id`

Permite cambiar el estado de una orden existente. Se valida que el nuevo estado pertenezca
a la lista de estados permitidos.

```
Estados permitidos: pending, confirmed, rejected
```

**Ejemplo del cuerpo que espera**

```json
{
  "status": "confirmed"
}
```
