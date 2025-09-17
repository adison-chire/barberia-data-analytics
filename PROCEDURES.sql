-- Procedimientos Almacenados SQL para Dashboards en Power BI

-- -----------------------------------------------------
-- 1. SP_GetSalesSummaryByDate
-- Propósito: Obtener un resumen de ventas (número de ventas y monto total) dentro de un rango de fechas.
-- Parámetros: @FechaInicio (DATE), @FechaFin (DATE)
-- -----------------------------------------------------
CREATE PROCEDURE SP_GetSalesSummaryByDate
    @FechaInicio DATE,
    @FechaFin DATE
AS
BEGIN
    SELECT
        v.fecha AS FechaVenta,
        COUNT(DISTINCT v.COD) AS NumeroDeVentas,
        SUM(f.monto_final) AS MontoTotalVentas
    FROM
        venta v
    JOIN
        factura f ON (f.ventaproducto_cod IN (SELECT COD FROM ventaproducto WHERE venta_cod = v.COD))
                     OR (f.ventaservicio_cod IN (SELECT COD FROM ventaservicio WHERE venta_cod = v.COD))
    WHERE
        v.fecha BETWEEN @FechaInicio AND @FechaFin
    GROUP BY
        v.fecha
    ORDER BY
        FechaVenta ASC;
END;
GO

-- Ejemplo de llamada:
EXEC SP_GetSalesSummaryByDate '2024-01-01', '2024-12-31';
-- GO

-- -----------------------------------------------------
-- 2. SP_GetTopCustomersBySales
-- Propósito: Identificar a los clientes que más han gastado, con un límite opcional.
-- Parámetros: @TopN (INT, opcional, por defecto 10)
-- -----------------------------------------------------
CREATE PROCEDURE SP_GetTopCustomersBySales
    @TopN INT = 10 -- Valor por defecto: 10 clientes
AS
BEGIN
    SELECT TOP (@TopN)
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
END;
GO

-- Ejemplo de llamada (obtener los 5 clientes principales):
EXEC SP_GetTopCustomersBySales 5;
-- GO
-- Ejemplo de llamada (obtener los 10 clientes principales por defecto):
-- EXEC SP_GetTopCustomersBySales;
-- GO

-- -----------------------------------------------------
-- 3. SP_GetEmployeeSalesPerformance
-- Propósito: Evaluar el rendimiento de ventas de los empleados, con filtrado por DNI y/o rango de fechas.
-- Parámetros: @EmpleadoDNI (VARCHAR(8), opcional), @FechaInicio (DATE, opcional), @FechaFin (DATE, opcional)
-- -----------------------------------------------------
CREATE PROCEDURE SP_GetEmployeeSalesPerformance
    @EmpleadoDNI VARCHAR(8) = NULL,
    @FechaInicio DATE = NULL,
    @FechaFin DATE = NULL
AS
BEGIN
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
    WHERE
        (@EmpleadoDNI IS NULL OR e.DNI = @EmpleadoDNI)
        AND (@FechaInicio IS NULL OR v.fecha >= @FechaInicio)
        AND (@FechaFin IS NULL OR v.fecha <= @FechaFin)
    GROUP BY
        e.DNI, e.nombre, e.apellido, e.email
    ORDER BY
        MontoTotalVentasGeneradas DESC;
END;
GO

-- Ejemplo de llamada (rendimiento de un empleado específico):
EXEC SP_GetEmployeeSalesPerformance @EmpleadoDNI = '62459163';
-- GO
-- Ejemplo de llamada (rendimiento de todos los empleados en un rango de fechas):
-- EXEC SP_GetEmployeeSalesPerformance @FechaInicio = '2024-01-01', @FechaFin = '2024-06-30';
-- GO
-- Ejemplo de llamada (rendimiento de un empleado específico en un rango de fechas):
-- EXEC SP_GetEmployeeSalesPerformance @EmpleadoDNI = '62459163', @FechaInicio = '2024-01-01', @FechaFin = '2024-03-31';
-- GO
-- Ejemplo de llamada (rendimiento de todos los empleados):
-- EXEC SP_GetEmployeeSalesPerformance;
-- GO

-- -----------------------------------------------------
-- 4. SP_GetTopSellingProducts
-- Propósito: Obtener los productos más vendidos por cantidad y/o ingresos, con un límite opcional.
-- Parámetros: @TopN (INT, opcional, por defecto 10), @OrderBy (VARCHAR(50), 'Cantidad' o 'Ingresos', por defecto 'Cantidad')
-- -----------------------------------------------------
CREATE PROCEDURE SP_GetTopSellingProducts
    @TopN INT = 10,
    @OrderBy VARCHAR(50) = 'Cantidad' -- Puede ser 'Cantidad' o 'Ingresos'
AS
BEGIN
    SELECT TOP (@TopN)
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
        CASE WHEN @OrderBy = 'Cantidad' THEN SUM(vp.cantidad) ELSE SUM(vp.precioventaproducto * vp.cantidad) END DESC,
        CASE WHEN @OrderBy = 'Ingresos' THEN SUM(vp.precioventaproducto * vp.cantidad) ELSE SUM(vp.cantidad) END DESC;
END;
GO

-- Ejemplo de llamada (los 5 productos más vendidos por cantidad):
EXEC SP_GetTopSellingProducts 5, 'Cantidad';
-- GO
-- Ejemplo de llamada (los 3 productos con mayores ingresos):
-- EXEC SP_GetTopSellingProducts 3, 'Ingresos';
-- GO
-- Ejemplo de llamada (los 10 productos más vendidos por cantidad por defecto):
-- EXEC SP_GetTopSellingProducts;
-- GO

-- -----------------------------------------------------
-- 5. SP_GetTopSellingServices
-- Propósito: Obtener los servicios más vendidos por ingresos, con un límite opcional.
-- Parámetros: @TopN (INT, opcional, por defecto 10)
-- -----------------------------------------------------
CREATE PROCEDURE SP_GetTopSellingServices
    @TopN INT = 10 -- Valor por defecto: 10 servicios
AS
BEGIN
    SELECT TOP (@TopN)
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
END;
GO

-- Ejemplo de llamada (los 5 servicios con mayores ingresos):
EXEC SP_GetTopSellingServices 5;
-- GO
-- Ejemplo de llamada (los 10 servicios con mayores ingresos por defecto):
-- EXEC SP_GetTopSellingServices;
-- GO

-- -----------------------------------------------------
-- 6. SP_GetInvoiceDetails
-- Propósito: Obtener los detalles completos de una factura específica.
-- Parámetros: @FacturaCOD (INT)
-- -----------------------------------------------------
CREATE PROCEDURE SP_GetInvoiceDetails
    @FacturaCOD INT
AS
BEGIN
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
        empleado e ON v.empleado_dni = e.DNI
    WHERE
        f.COD = @FacturaCOD;
END;
GO

-- Ejemplo de llamada (detalles de la factura con COD 1):
EXEC SP_GetInvoiceDetails 1;
-- GO
