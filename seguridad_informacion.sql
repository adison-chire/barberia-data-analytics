-- Script de Implementación de Seguridad en SQL Server para BD_Barbershop

-- *****************************************************
-- Sección 1: Creación de Logins (a nivel de instancia de SQL Server)
-- *****************************************************

-- 1.1. Crear Login para Autenticación de Windows (Recomendado)
-- Reemplaza '[TU_DOMINIO\NombreUsuarioWindows]' con el nombre de usuario o grupo de Windows real.
-- Si es un grupo de Windows, todos los miembros del grupo heredarán este login.
-- Ejemplo: CREATE LOGIN [MIEMPRESA\JuanPerez] FROM WINDOWS WITH DEFAULT_DATABASE = [BD_Barbershop];
-- Ejemplo: CREATE LOGIN [MIEMPRESA\GrupoContabilidad] FROM WINDOWS WITH DEFAULT_DATABASE = [BD_Barbershop];
CREATE LOGIN [TuDominio\UsuarioBarbero] FROM WINDOWS WITH DEFAULT_DATABASE = [BD_Barbershop];
CREATE LOGIN [TuDominio\UsuarioAdmin] FROM WINDOWS WITH DEFAULT_DATABASE = [BD_Barbershop];
CREATE LOGIN [TuDominio\UsuarioContable] FROM WINDOWS WITH DEFAULT_DATABASE = [BD_Barbershop];
GO

-- 1.2. Crear Login para Autenticación de SQL Server (si es necesario para aplicaciones o usuarios específicos)
-- Asegúrate de usar contraseñas fuertes y únicas.
CREATE LOGIN UsuarioSQLBarbero WITH PASSWORD = '123', CHECK_POLICY = ON, DEFAULT_DATABASE = [BD_Barbershop];
CREATE LOGIN UsuarioSQLAdmin WITH PASSWORD = '123', CHECK_POLICY = ON, DEFAULT_DATABASE = [BD_Barbershop];
CREATE LOGIN UsuarioSQLContable WITH PASSWORD = '123', CHECK_POLICY = ON, DEFAULT_DATABASE = [BD_Barbershop];
GO

-- *****************************************************
-- Sección 2: Creación de Usuarios (a nivel de base de datos BD_Barbershop)
-- *****************************************************

USE [BD_Barbershop];
GO

-- 2.1. Mapear Logins de Windows a Usuarios de Base de Datos
CREATE USER UsuarioBarbero_DB FOR LOGIN [TuDominio\UsuarioBarbero];
CREATE USER UsuarioAdmin_DB FOR LOGIN [TuDominio\UsuarioAdmin];
CREATE USER UsuarioContable_DB FOR LOGIN [TuDominio\UsuarioContable];
GO

-- 2.2. Mapear Logins de SQL Server a Usuarios de Base de Datos
CREATE USER UsuarioSQLBarbero_DB FOR LOGIN UsuarioSQLBarbero;
CREATE USER UsuarioSQLAdmin_DB FOR LOGIN UsuarioSQLAdmin;
CREATE USER UsuarioSQLContable_DB FOR LOGIN UsuarioSQLContable;
GO

-- *****************************************************
-- Sección 3: Creación de Roles de Base de Datos Personalizados
-- *****************************************************

USE [BD_Barbershop];
GO

-- Rol para barberos (principalmente operaciones de venta y consulta de productos/servicios)
CREATE ROLE Rol_Barbero;
GO

-- Rol para administradores (gestión completa de clientes, empleados, productos, servicios, ventas)
CREATE ROLE Rol_Administrador;
GO

-- Rol para contabilidad (principalmente consultas de ventas y facturas)
CREATE ROLE Rol_Contabilidad;
GO

-- *****************************************************
-- Sección 4: Asignación de Permisos a los Roles
-- *****************************************************

USE [BD_Barbershop];
GO

-- Permisos para Rol_Barbero
-- Puede ver clientes, empleados, productos y servicios.
-- Puede insertar y actualizar ventas y sus detalles (ventaproducto, ventaservicio).
GRANT SELECT ON cliente TO Rol_Barbero;
GRANT SELECT ON empleado TO Rol_Barbero;
GRANT SELECT ON producto TO Rol_Barbero;
GRANT SELECT ON servicio TO Rol_Barbero;

GRANT SELECT, INSERT, UPDATE ON venta TO Rol_Barbero;
GRANT SELECT, INSERT, UPDATE ON ventaproducto TO Rol_Barbero;
GRANT SELECT, INSERT, UPDATE ON ventaservicio TO Rol_Barbero;
-- Si los barberos necesitan ver facturas, pero no modificarlas
GRANT SELECT ON factura TO Rol_Barbero;

-- Permisos para Rol_Administrador
-- Control total sobre todas las tablas y objetos de la base de datos (excepto seguridad a nivel de servidor)
-- NOTA: db_owner es un rol fijo de base de datos que ya da control total.
-- Si quieres un control más granular, puedes otorgar permisos explícitamente como se muestra a continuación,
-- pero para un "Administrador" es común usar db_owner para simplificar.
-- Si usas db_owner, no necesitas los GRANTs individuales para tablas/vistas/SPs.
ALTER ROLE db_owner ADD MEMBER Rol_Administrador; -- Esto otorga control total sobre la BD

-- Si no usas db_owner para el administrador, aquí hay un ejemplo de permisos más granulares:
/*
GRANT SELECT, INSERT, UPDATE, DELETE ON cliente TO Rol_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON empleado TO Rol_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON producto TO Rol_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON servicio TO Rol_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON venta TO Rol_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON ventaproducto TO Rol_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON ventaservicio TO Rol_Administrador;
GRANT SELECT, INSERT, UPDATE, DELETE ON factura TO Rol_Administrador;
*/

-- Permisos para ejecutar todos los procedimientos almacenados y funciones
GRANT EXECUTE TO Rol_Administrador;
-- Permisos para ver todas las vistas
GRANT SELECT ON SCHEMA::dbo TO Rol_Administrador; -- Otorga SELECT en todos los objetos del esquema dbo

-- Permisos para Rol_Contabilidad
-- Principalmente consultas de ventas, facturas y reportes.
GRANT SELECT ON venta TO Rol_Contabilidad;
GRANT SELECT ON ventaproducto TO Rol_Contabilidad;
GRANT SELECT ON ventaservicio TO Rol_Contabilidad;
GRANT SELECT ON factura TO Rol_Contabilidad;
GRANT SELECT ON V_ResumenVentasPorFecha TO Rol_Contabilidad;
GRANT SELECT ON V_VentasPorCliente TO Rol_Contabilidad;
GRANT SELECT ON V_VentasPorEmpleado TO Rol_Contabilidad;
GRANT SELECT ON V_ProductosMasVendidos TO Rol_Contabilidad;
GRANT SELECT ON V_ServiciosMasVendidos TO Rol_Contabilidad;
GRANT SELECT ON V_DetalleFacturasCompleto TO Rol_Contabilidad;
GRANT SELECT ON V_NivelStockProductos TO Rol_Contabilidad;
-- Puede ejecutar procedimientos almacenados de informes
GRANT EXECUTE ON SP_GetSalesSummaryByDate TO Rol_Contabilidad;
GRANT EXECUTE ON SP_GetTopCustomersBySales TO Rol_Contabilidad;
GRANT EXECUTE ON SP_GetEmployeeSalesPerformance TO Rol_Contabilidad;
GRANT EXECUTE ON SP_GetTopSellingProducts TO Rol_Contabilidad;
GRANT EXECUTE ON SP_GetTopSellingServices TO Rol_Contabilidad;
GRANT EXECUTE ON SP_GetInvoiceDetails TO Rol_Contabilidad;
-- Puede usar las funciones para consultas
GRANT EXECUTE ON FUNCTION::dbo.FN_GetTotalSaleAmount TO Rol_Contabilidad;
GRANT EXECUTE ON FUNCTION::dbo.FN_GetProductName TO Rol_Contabilidad;
GRANT EXECUTE ON FUNCTION::dbo.FN_GetServiceName TO Rol_Contabilidad;
GRANT EXECUTE ON FUNCTION::dbo.FN_GetClientFullName TO Rol_Contabilidad;
GRANT EXECUTE ON FUNCTION::dbo.FN_GetEmployeeFullName TO Rol_Contabilidad;
GO

-- *****************************************************
-- Sección 5: Asignación de Usuarios a los Roles
-- *****************************************************

USE [BD_Barbershop];
GO

-- Asignar usuarios a sus roles correspondientes
ALTER ROLE Rol_Barbero ADD MEMBER UsuarioBarbero_DB;
ALTER ROLE Rol_Barbero ADD MEMBER UsuarioSQLBarbero_DB;

ALTER ROLE Rol_Administrador ADD MEMBER UsuarioAdmin_DB;
ALTER ROLE Rol_Administrador ADD MEMBER UsuarioSQLAdmin_DB;

ALTER ROLE Rol_Contabilidad ADD MEMBER UsuarioContable_DB;
ALTER ROLE Rol_Contabilidad ADD MEMBER UsuarioSQLContable_DB;
GO

-- *****************************************************
-- Verificación (Opcional)
-- *****************************************************

-- Para verificar los permisos de un usuario (reemplaza 'UsuarioBarbero_DB' con el usuario a verificar)
-- EXECUTE AS USER = 'UsuarioBarbero_DB';
-- SELECT * FROM cliente; -- Debería funcionar
-- INSERT INTO empleado (DNI, nombre, apellido, email) VALUES ('12345678', 'Test', 'User', 'test@example.com'); -- Debería fallar
-- REVERT;
-- GO

-- Para listar los roles y sus miembros
-- SELECT rp.name AS RoleName, mp.name AS MemberName
-- FROM sys.database_role_members drm
-- JOIN sys.database_principals rp ON drm.role_principal_id = rp.principal_id
-- JOIN sys.database_principals mp ON drm.member_principal_id = mp.principal_id
-- WHERE rp.type = 'R';
-- GO

-- Para listar los permisos otorgados a un rol específico (ej. Rol_Barbero)
-- SELECT
--     pr.permission_name,
--     obj.name AS ObjectName,
--     obj.type_desc AS ObjectType
-- FROM sys.database_permissions pr
-- JOIN sys.database_principals dp ON pr.grantee_principal_id = dp.principal_id
-- LEFT JOIN sys.objects obj ON pr.major_id = obj.object_id
-- WHERE dp.name = 'Rol_Barbero';
-- GO
