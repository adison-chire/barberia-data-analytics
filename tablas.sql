CREATE DATABASE BD_Barbershop;
-- Establecer el contexto de la base de datos si es necesario
USE BD_Barbershop;
GO

-- Bloque para manejo de errores y transacciones (opcional pero recomendado para scripts grandes)
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Crear Tabla Cliente
    CREATE TABLE cliente (
        DNI VARCHAR(8) PRIMARY KEY NOT NULL, -- DNI es un identificador único y no puede ser nulo
        nombre VARCHAR(50) NOT NULL,          -- El nombre del cliente debería ser obligatorio
        apellido VARCHAR(50) NOT NULL,        -- El apellido del cliente debería ser obligatorio
        telefono VARCHAR(9) NULL              -- El teléfono puede ser opcional (NULLable)
    );
  
    -- Crear Tabla Empleado
    CREATE TABLE empleado (
        DNI VARCHAR(8) PRIMARY KEY NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        apellido VARCHAR(50) NOT NULL,
        email VARCHAR(50) UNIQUE NOT NULL,    -- El email debería ser único para cada empleado y no nulo
        telefono VARCHAR(9) NULL,
        direccion VARCHAR(100) NULL
    );

    -- Crear Tabla Venta
    CREATE TABLE venta (
        COD INT IDENTITY(1,1) PRIMARY KEY NOT NULL, -- IDENTITY para auto-incremento, PK no nulo
        fecha DATE NOT NULL,                        -- La fecha de la venta es obligatoria
        cliente_dni VARCHAR(8) NOT NULL,            -- Toda venta debe tener un cliente asociado
        empleado_dni VARCHAR(8) NOT NULL,           -- Toda venta debe tener un empleado que la registró

        CONSTRAINT FK_Venta_Cliente FOREIGN KEY (cliente_dni) REFERENCES cliente(DNI),
        CONSTRAINT FK_Venta_Empleado FOREIGN KEY (empleado_dni) REFERENCES empleado(DNI)
    );

    -- Crear Tabla Producto
    CREATE TABLE producto (
        COD INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        nombre VARCHAR(50) NOT NULL,
        stock INT NOT NULL CHECK (stock >= 0), -- Stock no puede ser negativo
        precio DECIMAL(10,2) NOT NULL CHECK (precio >= 0) -- Precios siempre positivos y con precisión exacta
    );

    -- Crear Tabla VentaProducto (Detalle de productos en una venta)
    CREATE TABLE ventaproducto (
        COD INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        precioventaproducto DECIMAL(10,2) NOT NULL CHECK (precioventaproducto >= 0), -- Usar DECIMAL para dinero
        cantidad INT NOT NULL CHECK (cantidad > 0), -- La cantidad debe ser al menos 1
        venta_cod INT NOT NULL,
        producto_cod INT NOT NULL,

        CONSTRAINT FK_VentaProducto_Venta FOREIGN KEY (venta_cod) REFERENCES venta(COD),
        CONSTRAINT FK_VentaProducto_Producto FOREIGN KEY (producto_cod) REFERENCES producto(COD),
        CONSTRAINT UQ_VentaProducto UNIQUE (venta_cod, producto_cod) -- Una venta no puede tener el mismo producto dos veces
    );

    -- Crear Tabla Servicio
    CREATE TABLE servicio (
        COD INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        tipo VARCHAR(50) NULL, -- Tipo podría ser opcional
        nombre VARCHAR(50) NOT NULL,
        costo DECIMAL(10,2) NOT NULL CHECK (costo >= 0) -- Costo siempre positivo
    );

    -- Crear Tabla VentaServicio (Detalle de servicios en una venta)
    CREATE TABLE ventaservicio (
        COD INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        costoventaservicio DECIMAL(10,2) NOT NULL CHECK (costoventaservicio >= 0), -- Usar DECIMAL para dinero

        venta_cod INT NOT NULL,
        servicio_cod INT NOT NULL,

        CONSTRAINT FK_VentaServicio_Venta FOREIGN KEY (venta_cod) REFERENCES venta(COD),
        CONSTRAINT FK_VentaServicio_Servicio FOREIGN KEY (servicio_cod) REFERENCES servicio(COD),
        CONSTRAINT UQ_VentaServicio UNIQUE (venta_cod, servicio_cod) -- Una venta no puede tener el mismo servicio dos veces
    );

    -- Crear Tabla Factura (con relaciones 1 a 1 mejoradas)
    CREATE TABLE factura (
        COD INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
        fecha DATE NOT NULL,
        monto_final DECIMAL(10,2) NOT NULL CHECK (monto_final >= 0),

        ventaproducto_cod INT UNIQUE NOT NULL,
        ventaservicio_cod INT UNIQUE NOT NULL,

        CONSTRAINT FK_Factura_VentaProducto FOREIGN KEY (ventaproducto_cod) REFERENCES ventaproducto(COD),
        CONSTRAINT FK_Factura_VentaServicio FOREIGN KEY (ventaservicio_cod) REFERENCES ventaservicio(COD)

    );

    COMMIT TRANSACTION;
    PRINT 'Las tablas han sido creadas exitosamente.';
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Ocurrió un error. Se ha revertido la transacción.';
    PRINT ERROR_MESSAGE(); -- Mostrar el mensaje de error específico
END CATCH;
GO