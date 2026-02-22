USE MASTER

IF EXISTS (SELECT name FROM sys.databases WHERE name = 'Com2343')
BEGIN
   
   -- Terminar conexiones activas
   ALTER DATABASE [Com2343] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
   
    -- Eliminar la base
    DROP DATABASE Com2343;
END


-- ==========  CREACION DE BASE DE DATOS  =============
IF NOT EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name='Com2343') 
BEGIN
CREATE DATABASE Com2343
END
GO

ALTER DATABASE Com2343 SET MULTI_USER WITH ROLLBACK IMMEDIATE; --- PARA USAR EN VARIAS QUERYS A LA VEZ

USE Com2343

-- ==========  CREACION DE ESQUEMAS  =============
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'ct') -- CARGAR TABLAS
BEGIN
	EXEC('CREATE SCHEMA ct')
END 
GO


IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'csp') -- CARGAR SP
BEGIN
	EXEC('CREATE SCHEMA csp')
END 
GO

--  =================  CREACION DE TABLAS  =================
-- 1. CATEGORIA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Categoria')
BEGIN
    CREATE TABLE ct.Categoria (
        id_categoria INT PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        margen_ganancia DECIMAL(5,2)
    );
END
GO

-- 2. TEMPORADA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Temporada')
BEGIN
    CREATE TABLE ct.Temporada (
        id_temporada INT PRIMARY KEY,
        fecha_comienzo DATE,
        fecha_fin DATE
    );
END
GO

-- 3. PROVEEDOR
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Proveedor')
BEGIN
    CREATE TABLE ct.Proveedor (
        id_proveedor INT PRIMARY KEY,
        nya_prov VARCHAR(100) NOT NULL
    );
END
GO

-- 4. CAPACITADOR
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Capacitador')
BEGIN
    CREATE TABLE ct.Capacitador (
        id_capacitador INT PRIMARY KEY,
        nya_capacitador VARCHAR(100) NOT NULL
    );
END
GO

-- 5. SUCURSAL
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Sucursal')
BEGIN
    CREATE TABLE ct.Sucursal (
        id_sucursal INT PRIMARY KEY,
        ubicacion VARCHAR(100)
    );
END
GO

-- 6. CLIENTE
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Cliente')
BEGIN
    CREATE TABLE ct.Cliente (
        id_cliente INT PRIMARY KEY,
        tipo VARCHAR(50) -- registrado/consumidor final
    );
END
GO

-- 7. VENDEDOR
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Vendedor')
BEGIN
    CREATE TABLE ct.Vendedor (
        id_vendedor INT PRIMARY KEY,
        id_sucursal INT FOREIGN KEY REFERENCES ct.Sucursal(id_sucursal)
    );
END
GO

-- 8. CERTIFICADO (Relación entre Vendedor y Capacitador)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Certificado')
BEGIN
    CREATE TABLE ct.Certificado (
        id_certificado INT PRIMARY KEY,
        fecha_capacitacion DATE,
        id_vendedor INT FOREIGN KEY REFERENCES ct.Vendedor(id_vendedor),
        id_capacitador INT FOREIGN KEY REFERENCES ct.Capacitador(id_capacitador)
    );
END
GO

-- 9. PRODUCTO
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Producto')
BEGIN
    CREATE TABLE ct.Producto (
        id_producto INT PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        tipo_producto VARCHAR(10), -- Granel/Unidad
        tipo VARCHAR(50),
        vida_util VARCHAR(50),
        id_categoria INT FOREIGN KEY REFERENCES ct.Categoria(id_categoria),
        id_temporada INT FOREIGN KEY REFERENCES ct.Temporada(id_temporada)
    );
END
GO

-- 10. STOCK (Relación Sucursal - Producto)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Stock')
BEGIN
    CREATE TABLE ct.Stock (
        id_stock INT PRIMARY KEY,
        id_sucursal INT FOREIGN KEY REFERENCES ct.Sucursal(id_sucursal),
        id_producto INT FOREIGN KEY REFERENCES ct.Producto(id_producto)
    );
END
GO

-- 11. LISTA DE PRECIO (Relación Producto - Proveedor)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Lista_Precio')
BEGIN
    CREATE TABLE ct.Lista_Precio (
        id_lista INT PRIMARY KEY,
        formato VARCHAR(50),
        id_producto INT FOREIGN KEY REFERENCES ct.Producto(id_producto),
        id_proveedor INT FOREIGN KEY REFERENCES ct.Proveedor(id_proveedor)
    );
END
GO

-- 12. LOTE
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Lote')
BEGIN
    CREATE TABLE ct.Lote (
        id_lote INT PRIMARY KEY,
        fecha_ingreso DATE,
        fecha_vencimiento DATE,
        cantidad_inicial INT,
        cantidad_actual INT,
        costo DECIMAL(18,2),
        id_producto INT FOREIGN KEY REFERENCES ct.Producto(id_producto)
    );
END
GO

-- 13. VENTA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Venta')
BEGIN
    CREATE TABLE ct.Venta (
        id_venta INT PRIMARY KEY,
        modalidad VARCHAR(50), -- presencial/domicilio
        recepcion_pedido VARCHAR(50), -- propio/plataforma
        id_vendedor INT FOREIGN KEY REFERENCES ct.Vendedor(id_vendedor),
        id_cliente INT FOREIGN KEY REFERENCES ct.Cliente(id_cliente)
    );
END
GO

-- 14. DETALLE VENTA (Relación Venta - Lote)
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Detalle_Venta')
BEGIN
    CREATE TABLE ct.Detalle_Venta (
        id_venta INT FOREIGN KEY REFERENCES ct.Venta(id_venta),
        id_lote INT FOREIGN KEY REFERENCES ct.Lote(id_lote),
        cantidad INT,
        precio_unitario DECIMAL(18,2),
        PRIMARY KEY (id_venta, id_lote)
    );
END
GO

