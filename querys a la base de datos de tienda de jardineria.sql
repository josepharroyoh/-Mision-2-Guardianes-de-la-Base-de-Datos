/*------------------------------------------------------------------------------------------------------------------------------*/
/*Identificar al Cliente Más Valioso de Cada Representante de Ventas*/
/*------------------------------------------------------------------------------------------------------------------------------*/

WITH GastoPorCliente AS (
    -- Paso 1: Calcular el gasto total de cada cliente.
    SELECT 
        p.codigo_cliente,
        SUM(dp.cantidad * dp.precio_unidad) AS gasto_total
    FROM pedido p
    JOIN detalle_pedido dp ON p.codigo_pedido = dp.codigo_pedido
    GROUP BY p.codigo_cliente
),
ClientesRankeados AS (
    -- Paso 2: Rankear a los clientes por gasto para cada representante de ventas.
    SELECT
        c.codigo_empleado_rep_ventas,
        c.nombre_cliente,
        gpc.gasto_total,
        RANK() OVER(PARTITION BY c.codigo_empleado_rep_ventas ORDER BY gpc.gasto_total DESC) as ranking
    FROM cliente c
    JOIN GastoPorCliente gpc ON c.codigo_cliente = gpc.codigo_cliente
)
-- Paso 3: Seleccionar el cliente con el ranking #1 para cada representante y unirlo con el nombre del empleado.
SELECT
    CONCAT(e.nombre, ' ', e.apellido1) AS 'Nombre del Representante',
    cr.nombre_cliente AS 'Cliente Más Valioso',
    cr.gasto_total AS 'Gasto Total del Cliente'
FROM ClientesRankeados cr
JOIN empleado e ON cr.codigo_empleado_rep_ventas = e.codigo_empleado
WHERE cr.ranking = 1;
/*------------------------------------------------------------------------------------------------------------------------------*/
/*Análisis de Rendimiento por Gama de Producto*/
/*------------------------------------------------------------------------------------------------------------------------------*/

WITH CalculosPorProducto AS (
    -- Paso 1: Calcular ventas totales y ganancias totales por cada producto.
    SELECT
        dp.codigo_producto,
        SUM(dp.cantidad * dp.precio_unidad) AS ventas_totales,
        SUM(dp.cantidad * (p.precio_venta - p.precio_proveedor)) AS ganancias_totales
    FROM detalle_pedido dp
    JOIN producto p ON dp.codigo_producto = p.codigo_producto
    GROUP BY dp.codigo_producto
),
ProductosRankeados AS (
    -- Paso 2: Rankear los productos dentro de cada gama por ventas y ganancias.
    SELECT
        p.gama,
        p.nombre AS nombre_producto,
        cvp.ventas_totales,
        cvp.ganancias_totales,
        ROW_NUMBER() OVER(PARTITION BY p.gama ORDER BY cvp.ventas_totales DESC) AS ranking_ventas,
        ROW_NUMBER() OVER(PARTITION BY p.gama ORDER BY cvp.ganancias_totales ASC) AS ranking_ganancias
    FROM producto p
    JOIN CalculosPorProducto cvp ON p.codigo_producto = cvp.codigo_producto
)
-- Paso 3: Seleccionar el producto #1 en ventas y el #1 en pérdidas para cada gama.
SELECT
    g.gama,
    g.descripcion_texto,
    'Producto Más Vendido' AS tipo,
    pr.nombre_producto,
    pr.ventas_totales AS valor
FROM ProductosRankeados pr
JOIN gama_producto g ON pr.gama = g.gama
WHERE pr.ranking_ventas = 1
UNION ALL
SELECT
    g.gama,
    g.descripcion_texto,
    'Producto Menos Rentable' AS tipo,
    pr.nombre_producto,
    pr.ganancias_totales AS valor
FROM ProductosRankeados pr
JOIN gama_producto g ON pr.gama = g.gama
WHERE pr.ranking_ganancias = 1;
