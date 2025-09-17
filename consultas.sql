-- Consultas SQL para Dashboards en Power BI
use BD_Barbershop
-- -----------------------------------------------------
-- tendencias de ventas a lo largo del tiempo.
-- Agrupar por día, semana, mes o año en Power BI.
-- -----------------------------------------------------
-- 1. Resumen de Ventas por Fecha
SELECT
    v.fecha AS FechaVenta,
    COUNT(DISTINCT v.COD) AS NumeroDeVentas,
    SUM(f.monto_final) AS MontoTotalVentas
FROM
    venta v
JOIN
    factura f ON (f.ventaproducto_cod IN (SELECT COD FROM ventaproducto WHERE venta_cod = v.COD))
                 OR (f.ventaservicio_cod IN (SELECT COD FROM ventaservicio WHERE venta_cod = v.COD))
GROUP BY
    v.fecha
ORDER BY
    FechaVenta ASC;
GO

-- -----------------------------------------------------
-- identificar a los clientes más valiosos y analizar su comportamiento de compra.
-- -----------------------------------------------------
-- 2. Ventas por Cliente
SELECT
    c.DNI AS ClienteDNI,
    c.nombre AS ClienteNombre,
    c.apellido AS ClienteApellido,
    c.telefono AS ClienteTelefono,
    COUNT(DISTINCT v.COD) AS NumeroDeVentas,
    SUM(f.monto_final) AS MontoTotalGastado
FROM
    cliente c
JOIN
    venta v ON c.DNI = v.cliente_dni
JOIN
    factura f ON (f.ventaproducto_cod IN (SELECT COD FROM ventaproducto WHERE venta_cod = v.COD))
                 OR (f.ventaservicio_cod IN (SELECT COD FROM ventaservicio WHERE venta_cod = v.COD))
GROUP BY
    c.DNI, c.nombre, c.apellido, c.telefono
ORDER BY
    MontoTotalGastado DESC;
GO

-- -----------------------------------------------------
-- Permite evaluar el rendimiento de los empleados en términos de ventas generadas.
-- -----------------------------------------------------
-- 3. Ventas por Empleado
SELECT
    e.DNI AS EmpleadoDNI,
    e.nombre AS EmpleadoNombre,
    e.apellido AS EmpleadoApellido,
    e.email AS EmpleadoEmail,
    COUNT(DISTINCT v.COD) AS NumeroDeVentasAsignadas,
    SUM(f.monto_final) AS MontoTotalVentasGeneradas
FROM
    empleado e
JOIN
    venta v ON e.DNI = v.empleado_dni
JOIN
    factura f ON (f.ventaproducto_cod IN (SELECT COD FROM ventaproducto WHERE venta_cod = v.COD))
                 OR (f.ventaservicio_cod IN (SELECT COD FROM ventaservicio WHERE venta_cod = v.COD))
GROUP BY
    e.DNI, e.nombre, e.apellido, e.email
ORDER BY
    MontoTotalVentasGeneradas DESC;
GO

-- -----------------------------------------------------
-- Útil para la gestión de inventario y para identificar productos estrella.
-- -----------------------------------------------------
-- 4. Productos Más Vendidos (por Cantidad y por Ingresos)
SELECT
    p.COD AS ProductoCOD,
    p.nombre AS NombreProducto,
    SUM(vp.cantidad) AS CantidadTotalVendida,
    SUM(vp.precioventaproducto * vp.cantidad) AS IngresosPorProducto
FROM
    ventaproducto vp
JOIN
    producto p ON vp.producto_cod = p.COD
GROUP BY
    p.COD, p.nombre
ORDER BY
    CantidadTotalVendida DESC, IngresosPorProducto DESC;
GO

-- -----------------------------------------------------

-- Ayuda a entender qué servicios son los más rentables o demandados.
-- -----------------------------------------------------
-- 5. Servicios Más Vendidos (por Ingresos)
SELECT
    s.COD AS ServicioCOD,
    s.nombre AS NombreServicio,
    SUM(vs.costoventaservicio) AS IngresosPorServicio
FROM
    ventaservicio vs
JOIN
    servicio s ON vs.servicio_cod = s.COD
GROUP BY
    s.COD, s.nombre
ORDER BY
    IngresosPorServicio DESC;
GO

-- -----------------------------------------------------
-- Proporciona una vista detallada de cada factura, incluyendo productos y servicios.
-- Esto puede ser una tabla base para múltiples visualizaciones en Power BI.
-- -----------------------------------------------------
-- 6. Detalle Completo de Facturas
SELECT
    f.COD AS FacturaCOD,
    f.fecha AS FacturaFecha,
    f.monto_final AS FacturaMontoFinal,
    c.nombre AS ClienteNombre,
    c.apellido AS ClienteApellido,
    e.nombre AS EmpleadoNombre,
    e.apellido AS EmpleadoApellido,
    p.nombre AS ProductoFacturado,
    vp.cantidad AS CantidadProducto,
    vp.precioventaproducto AS PrecioUnitarioProducto,
    s.nombre AS ServicioFacturado,
    vs.costoventaservicio AS CostoServicio
FROM
    factura f
JOIN
    ventaproducto vp ON f.ventaproducto_cod = vp.COD
JOIN
    producto p ON vp.producto_cod = p.COD
JOIN
    ventaservicio vs ON f.ventaservicio_cod = vs.COD
JOIN
    servicio s ON vs.servicio_cod = s.COD
JOIN
    venta v ON (vp.venta_cod = v.COD OR vs.venta_cod = v.COD) -- Asumiendo que ambas líneas de detalle pertenecen a la misma venta
JOIN
    cliente c ON v.cliente_dni = c.DNI
JOIN
    empleado e ON v.empleado_dni = e.DNI;
GO

-- -----------------------------------------------------
-- Para un dashboard de inventario que muestre el estado actual del stock.
-- -----------------------------------------------------
-- 7. Nivel de Stock de Productos
SELECT
    COD AS ProductoCOD,
    nombre AS NombreProducto,
    stock AS StockActual,
    precio AS PrecioUnitario
FROM
    producto
ORDER BY
    StockActual ASC;
GO
