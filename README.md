# Reto semana 2 con SQL: Guardianes de la Base de Datos utilizando la Base de Datos "Jardineria" 🚀

Este repositorio contiene la solución al reto "Guardianes de la Base de Datos" del programa de @360competenciasdigitales. El proyecto abarca desde el diseño y modelado de una base de datos relacional hasta la ejecución de consultas SQL avanzadas para extraer insights de negocio.

---

## 🏛️ Diagrama Entidad-Relación (MER)

El primer paso fue analizar y modelar la estructura de la base de datos `jardineria`. El siguiente diagrama representa las tablas, sus atributos y las relaciones entre ellas.

![Diagrama MER de la Base de Datos Jardineria]([URL_DE_TU_IMAGEN_DEL_MER.png](https://github.com/josepharroyoh/-Mision-2-Guardianes-de-la-Base-de-Datos/blob/main/ER%20DIAGRAM%20BASE%20DE%20DATOS%20JARDINERIA.png))

---

## 🛠️ Habilidades Demostradas

Este proyecto me permitió aplicar y demostrar conocimientos en las siguientes áreas:

* **Modelado de Datos**: Diseño y comprensión de esquemas relacionales (MER).
* **Consultas SQL Avanzadas**: Escritura de código SQL complejo para resolver problemas de negocio.
* **JOINs**: Combinación de datos de múltiples tablas para crear un conjunto de resultados unificado.
* **CTEs (Common Table Expressions)**: Uso de la cláusula `WITH` para mejorar la legibilidad y estructura de las consultas.
* **Funciones de Ventana**: Aplicación de `RANK()` y `ROW_NUMBER()` para realizar análisis y rankings sofisticados.
* **Agregaciones y Agrupaciones**: Uso de `SUM()` y `GROUP BY` para resumir datos.
* **Optimización de Consultas**: Comprensión de la eficiencia y la importancia de los índices.

---

## 🎯 Desafíos y Consultas SQL

A continuación se presentan las consultas principales desarrolladas para resolver los retos planteados.

### 1. Análisis de Cartera de Clientes: "El Cliente Más Valioso"

**Objetivo:** Identificar, para cada representante de ventas, cuál de sus clientes ha generado el mayor volumen de gasto total.

```sql
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
