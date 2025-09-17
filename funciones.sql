-- -----------------------------------------------------
-- Funciones SQL para Dashboards en Power BI
-- -----------------------------------------------------

-- Funci�n: FN_GetTotalSaleAmount
-- Prop�sito: Calcula el monto total de una venta espec�fica sumando productos y servicios.
-- Par�metros: @VentaCOD (INT)
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

-- Funci�n: FN_GetProductName
-- Prop�sito: Obtiene el nombre de un producto dado su COD.
-- Par�metros: @ProductoCOD (INT)
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

-- Funci�n: FN_GetServiceName
-- Prop�sito: Obtiene el nombre de un servicio dado su COD.
-- Par�metros: @ServicioCOD (INT)
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

-- Funci�n: FN_GetClientFullName
-- Prop�sito: Combina el nombre y apellido de un cliente dado su DNI.
-- Par�metros: @ClienteDNI (VARCHAR(8))
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

-- Funci�n: FN_GetEmployeeFullName
-- Prop�sito: Combina el nombre y apellido de un empleado dado su DNI.
-- Par�metros: @EmpleadoDNI (VARCHAR(8))
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
