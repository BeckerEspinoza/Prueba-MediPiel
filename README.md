# Prueba-MediPiel

Solución de integración entre una plataforma externa de órdenes y un servicio interno
de procesamiento, compuesta por una API externa simulada y un servicio integrador,
ambos conectados a una base de datos PostgreSQL.

## Arquitectura

```
┌─────────────────────┐        HTTP        ┌──────────────────────┐
│  Servicio Integrador│ ────────────────── │    API Externa       │
│  (internal-service) │                    │    (api-externa)     │
└────────┬────────────┘                    └──────────┬───────────┘
         │                                            │
         │ PostgreSQL                                 │ PostgreSQL
         │ (inventory_movements, products)            │ (orders, products, customers)
         └────────────────────┬───────────────────────┘
                              │
                    ┌─────────▼─────────┐
                    │    PostgreSQL      │
                    │    medipiel DB    │
                    └───────────────────┘
```

## Base de datos

### Crear e inicializar la base de datos

```bash
psql -U tu_usuario -d tu_base -f sql/medipiel.sql
```

El script crea las siguientes tablas con sus relaciones, índices y datos de ejemplo:

- `customers` — clientes registrados
- `products` — catálogo de productos con stock
- `orders` — órdenes de compra
- `order_items` — productos por orden
- `inventory_movements` — movimientos de inventario registrados por el servicio integrador

---

## API Externa

### Instalación de dependencias

Usa el manejador de paquetes de Node.js para instalar dependencias

```bash
cd api-external
npm install
```

### Variables de entorno

```bash
cp .env.example .env
```

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tu_base
DB_USER=tu_usuario
DB_PASSWORD=tu_password
APP_PORT=3000
```

### Inicializar el Servidor

Usa el script para levantar el servidor de la API

```bash
npm run dev
```

### Endpoints

#### Obtener lista de productos

`GET /products`

Devuelve una lista de los productos existentes en la BD.

#### Obtener lista del inventario

`GET /products/stock`

Devuelve una lista que muestra Nombre del producto y su Stock.

#### Crear una Orden

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

#### Consultar una Orden por Id

`GET /orders/:order_id`

Devuelve la información completa de una Orden específica, incluyendo los datos generales
y el listado detallado de productos adquiridos mediante un `INNER JOIN`.

#### Actualizar el estado de Orden

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

#### Resumen de órdenes

`GET /orders/summary`

Devuelve un resumen agrupado por estatus con total de órdenes, piezas vendidas y monto total.

```json
{
  "success": true,
  "data": [
    {
      "status": "confirmed",
      "total_orders": 3,
      "total_pieces": 3,
      "total_amount": 3501.0
    }
  ]
}
```

## Servicio Integrador

Proyecto independiente que consume la API externa y ejecuta el flujo de negocio
para el procesamiento de órdenes.

### Instalación

```bash
cd servicio-interno
npm install
```

### Variables de entorno

```bash
cp .env.example .env
```

```env
DB_HOST=localhost
DB_PORT=5432
DB_NAME=tu_base
DB_USER=tu_usuario
DB_PASSWORD=tu_password

API_URL=http://localhost:3000
```

### Ejecución

```bash
node index.js
```

Ejemplo:

```bash
node index.js 1
```

### Flujo de procesamiento

1. Consulta la orden por ID en la API externa
2. Verifica que la orden esté en estado `pending`
3. Obtiene el stock actual de todos los productos
4. Valida si hay inventario suficiente para cada producto de la orden
5. Si hay stock suficiente:
   - Registra los movimientos en `inventory_movements`
   - Descuenta el stock en `products`
   - Actualiza el estado de la orden a `confirmed`
6. Si no hay stock suficiente:
   - Actualiza el estado de la orden a `rejected`
7. Deja evidencia del procesamiento en consola

## Decisiones técnicas

- **Transacción atómica**: los registros en `inventory_movements` y el descuento de stock
  en `products` se ejecutan dentro de una misma transacción PostgreSQL, garantizando
  consistencia ante cualquier fallo.

## Limitaciones conocidas

- El servicio integrador se ejecuta manualmente por línea de comandos, no hay un proceso
  automático que consuma órdenes pendientes.

## Mejoras futuras

- Agregar autenticación mediante JWT a la API externa.
- Agregar una tabla de `processing_logs` para persistir la evidencia del procesamiento
  en base de datos además de los logs en consola.
- Dockerizar ambos proyectos para simplificar el despliegue.

## Uso de IA

Durante el desarrollo se utilizó Claude (Anthropic) como apoyo para:

- Diseño del Modelo de Datos (PostgreSQL): Se utilizó la IA para proponer la estructura de tablas (orders, inventory_movements, etc.) y sus restricciones de integridad.
- Arquitectura de Microservicios: Apoyo en la definición del flujo de comunicación desacoplado entre la API Externa y el Servicio Integrador.
  Se evaluó el uso de Triggers vs lógica en el integrador optando más por la lógica en el servicio para que éste tuviera tareas por realizar.
- Redacción de este README

## Uso de Herramientas

- Documentación del paquete de npm pg.
- Documentación del motor de Postgres.
- StackOverflow.
