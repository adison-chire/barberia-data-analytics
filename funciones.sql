-- -----------------------------------------------------
-- Funciones SQL para Dashboards en Power BI
-- -----------------------------------------------------

-- Función: FN_GetTotalSaleAmount
-- Propósito: Calcula el monto total de una venta específica sumando productos y servicios.
-- Parámetros: @VentaCOD (INT)
-- Retorna: DECIMAL(10,2)
-- -----------------------------------------------------
CREATE FUNCTION FN_GetTotalSaleAmount
(
    @VentaCOD INT
)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @TotalMonto DECIMAL(10,2);

    SELECT @TotalMonto = ISNULL(SUM(vp.precioventaproducto * vp.cantidad), 0)
                         + ISNULL(SUM(vs.costoventaservicio), 0)
    FROM venta v
    LEFT JOIN ventaproducto vp ON v.COD = vp.venta_cod
    LEFT JOIN ventaservicio vs ON v.COD = vs.venta_cod
    WHERE v.COD = @VentaCOD;

    RETURN @TotalMonto;
END;
GO

-- Ejemplo de llamada:
SELECT dbo.FN_GetTotalSaleAmount(1) AS TotalVenta;
GO

-- Función: FN_GetProductName
-- Propósito: Obtiene el nombre de un producto dado su COD.
-- Parámetros: @ProductoCOD (INT)
-- Retorna: VARCHAR(50)
-- -----------------------------------------------------
CREATE FUNCTION FN_GetProductName
(
    @ProductoCOD INT
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @NombreProducto VARCHAR(50);

    SELECT @NombreProducto = nombre
    FROM producto
    WHERE COD = @ProductoCOD;

    RETURN ISNULL(@NombreProducto, 'Producto Desconocido');
END;
GO

-- Ejemplo de llamada:
SELECT dbo.FN_GetProductName(21) AS NombreDeProducto;
go

-- Función: FN_GetServiceName
-- Propósito: Obtiene el nombre de un servicio dado su COD.
-- Parámetros: @ServicioCOD (INT)
-- Retorna: VARCHAR(50)
-- -----------------------------------------------------
CREATE FUNCTION FN_GetServiceName
(
    @ServicioCOD INT
)
RETURNS VARCHAR(50)
AS
BEGIN
    DECLARE @NombreServicio VARCHAR(50);

    SELECT @NombreServicio = nombre
    FROM servicio
    WHERE COD = @ServicioCOD;

    RETURN ISNULL(@NombreServicio, 'Servicio Desconocido');
END;
GO

-- Ejemplo de llamada:
SELECT dbo.FN_GetServiceName(1) AS NombreDeServicio;
GO

-- Función: FN_GetClientFullName
-- Propósito: Combina el nombre y apellido de un cliente dado su DNI.
-- Parámetros: @ClienteDNI (VARCHAR(8))
-- Retorna: VARCHAR(101)
-- -----------------------------------------------------
CREATE FUNCTION FN_GetClientFullName
(
    @ClienteDNI VARCHAR(8)
)
RETURNS VARCHAR(101)
AS
BEGIN
    DECLARE @FullName VARCHAR(101);

    SELECT @FullName = nombre + ' ' + apellido
    FROM cliente
    WHERE DNI = @ClienteDNI;

    RETURN ISNULL(@FullName, 'Cliente Desconocido');
END;
GO

-- Ejemplo de llamada:
SELECT dbo.FN_GetClientFullName('77512395') AS NombreCompletoCliente;
GO

-- Función: FN_GetEmployeeFullName
-- Propósito: Combina el nombre y apellido de un empleado dado su DNI.
-- Parámetros: @EmpleadoDNI (VARCHAR(8))
-- Retorna: VARCHAR(101)
-- -----------------------------------------------------
CREATE FUNCTION FN_GetEmployeeFullName
(
    @EmpleadoDNI VARCHAR(8)
)
RETURNS VARCHAR(101)
AS
BEGIN
    DECLARE @FullName VARCHAR(101);

    SELECT @FullName = nombre + ' ' + apellido
    FROM empleado
    WHERE DNI = @EmpleadoDNI;

    RETURN ISNULL(@FullName, 'Empleado Desconocido');
END;
GO

-- Ejemplo de llamada:
SELECT dbo.FN_GetEmployeeFullName('62459163') AS NombreCompletoEmpleado;
GO
