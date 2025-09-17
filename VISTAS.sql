-- -----------------------------------------------------
-- Vistas SQL para Dashboards en Power BI
-- -----------------------------------------------------

-- Vista: V_ResumenVentasPorFecha
-- Propósito: Resumir las ventas totales y el número de ventas por fecha.
CREATE VIEW V_ResumenVentasPorFecha AS
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
    v.fecha;
GO

-- Llamar a la vista V_ResumenVentasPorFecha
SELECT * FROM V_ResumenVentasPorFecha;
GO

-- Vista: V_VentasPorCliente
-- Propósito: Identificar el número de ventas y el monto total gastado por cada cliente.
CREATE VIEW V_VentasPorCliente AS
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
    c.DNI, c.nombre, c.apellido, c.telefono;
GO

-- Llamar a la vista V_VentasPorCliente
SELECT * FROM V_VentasPorCliente;
GO

-- Vista: V_VentasPorEmpleado
-- Propósito: Evaluar el rendimiento de ventas de cada empleado.
CREATE VIEW V_VentasPorEmpleado AS
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
    e.DNI, e.nombre, e.apellido, e.email;
GO

-- Llamar a la vista V_VentasPorEmpleado
SELECT * FROM V_VentasPorEmpleado;
GO

-- Vista: V_ProductosMasVendidos
-- Propósito: Mostrar los productos más vendidos por cantidad y por ingresos.
CREATE VIEW V_ProductosMasVendidos AS
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
    p.COD, p.nombre;
GO

-- Llamar a la vista V_ProductosMasVendidos
SELECT * FROM V_ProductosMasVendidos;
GO

-- Vista: V_ServiciosMasVendidos
-- Propósito: Mostrar los servicios más vendidos por ingresos.
CREATE VIEW V_ServiciosMasVendidos AS
SELECT
    s.COD AS ServicioCOD,
    s.nombre AS NombreServicio,
    SUM(vs.costoventaservicio) AS IngresosPorServicio
FROM
    ventaservicio vs
JOIN
    servicio s ON vs.servicio_cod = s.COD
GROUP BY
    s.COD, s.nombre;
GO

-- Llamar a la vista V_ServiciosMasVendidos
SELECT * FROM V_ServiciosMasVendidos;
GO

-- Vista: V_DetalleFacturasCompleto
-- Propósito: Proporcionar una vista detallada de cada factura, incluyendo información de cliente, empleado, productos y servicios.
CREATE VIEW V_DetalleFacturasCompleto AS
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
    venta v ON (vp.venta_cod = v.COD OR vs.venta_cod = v.COD)
JOIN
    cliente c ON v.cliente_dni = c.DNI
JOIN
    empleado e ON v.empleado_dni = e.DNI;
GO

-- Llamar a la vista V_DetalleFacturasCompleto
SELECT * FROM V_DetalleFacturasCompleto;
GO

-- Vista: V_NivelStockProductos
-- Propósito: Mostrar el estado actual del stock de cada producto.
CREATE VIEW V_NivelStockProductos AS
SELECT
    COD AS ProductoCOD,
    nombre AS NombreProducto,
    stock AS StockActual,
    precio AS PrecioUnitario
FROM
    producto;
GO

-- Llamar a la vista V_NivelStockProductos
SELECT * FROM V_NivelStockProductos;
GO
