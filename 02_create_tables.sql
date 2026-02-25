
/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
	Componentes del grupo:
		-Leonel Cespedes
		-Luciana Franchetti


    Descripción: Creación de las tablas de la base Com2343
*/

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

-- ==============================
-- 1. SUCURSAL
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Sucursal')
BEGIN
    CREATE TABLE ct.Sucursal (
        id_sucursal INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        direccion VARCHAR(200) NOT NULL,
    );
END
GO

-- ==============================
-- 2. STOCK
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Stock')
BEGIN
    CREATE TABLE ct.Stock (
        id_stock INT IDENTITY(1,1) PRIMARY KEY,
        id_sucursal INT NOT NULL,
        stock_minimo INT NOT NULL,
        fecha_ultima_actualizacion DATETIME NOT NULL,
       
        CONSTRAINT FK_Stock_Sucursal 
            FOREIGN KEY (id_sucursal) REFERENCES ct.Sucursal(id_sucursal),
    );
END
GO

-- ==============================
-- 3. TEMPORADA
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Temporada')
BEGIN
    CREATE TABLE ct.Temporada (
        id_temporada INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
		descripcion VARCHAR(50) NOT NULL,
        fecha_inicio DATE NOT NULL,
        fecha_fin DATE NOT NULL
    );
END
GO

-- ==============================
-- 4. CATEGORIA
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Categoria')
BEGIN
    CREATE TABLE ct.Categoria (
        id_categoria INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        margen_ganancia DECIMAL(5,2) NOT NULL
    );
END
GO


-- ==============================
-- 5. PROVEEDOR
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Proveedor')
BEGIN
    CREATE TABLE ct.Proveedor (
        id_proveedor INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
		apellido VARCHAR(100) NOT NULL,
        telefono VARCHAR(20),
        cuit VARCHAR(100),
		CONSTRAINT ck_cuit CHECK (cuit LIKE '[0-9][0-9]-[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]-[0-9]')
    );
END
GO

-- ==============================
-- 6. PRODUCTO
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Producto')
BEGIN
    CREATE TABLE ct.Producto (
        id_producto INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
		descripcion VARCHAR(100),
        forma_comercializacion VARCHAR(50) NOT NULL,
		tipo_producto_agricola VARCHAR(50) NOT NULL,
        vida_util INT NOT NULL,
        id_categoria INT NOT NULL,
		id_stock INT NULL,
		id_temporada INT NULL,
		id_proveedor INT NULL,
        FOREIGN KEY (id_proveedor) REFERENCES ct.Proveedor(id_proveedor),
        FOREIGN KEY (id_temporada) REFERENCES ct.Temporada(id_temporada),
        FOREIGN KEY (id_stock) REFERENCES ct.Stock(id_stock),
		FOREIGN KEY (id_categoria) REFERENCES ct.Categoria(id_categoria),
		CONSTRAINT CK_Producto_TipoProducto CHECK (forma_comercializacion IN ('granel', 'unidad')),
		CONSTRAINT CK_Producto_Tipo CHECK (tipo_producto_agricola IN ('hoja verde', 'tuberculo'))
        
    );
END
GO


-- ==============================
-- 7. LISTA_PRECIO
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'ListaPrecio')
BEGIN
    CREATE TABLE ct.ListaPrecio (
	id_ListaPrecio INT NOT NULL,
    id_producto INT NOT NULL,
    id_proveedor INT NOT NULL,
    formato VARCHAR(10) NOT NULL,

    CONSTRAINT PK_ListaPrecio 
        PRIMARY KEY (id_producto, id_proveedor, id_ListaPrecio),

    CONSTRAINT CK_ListaPrecio_Formato 
        CHECK (formato IN ('json','csv')),

    FOREIGN KEY (id_producto) REFERENCES ct.Producto(id_producto),
    FOREIGN KEY (id_proveedor) REFERENCES ct.Proveedor(id_proveedor)
);
END
GO

-- ==============================
-- 8. LOTE
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Lote')
BEGIN
    CREATE TABLE ct.Lote (
        id_lote INT NOT NULL,
        id_producto INT NOT NULL,
        cantidad_inicial INT NOT NULL,
        costo DECIMAL(10,2) NOT NULL,
        fecha_ingreso DATE NOT NULL,
        fecha_vencimiento DATE NOT NULL,

		CONSTRAINT PK_Lote 
			PRIMARY KEY (id_lote , id_producto ),
        FOREIGN KEY (id_producto) REFERENCES ct.Producto(id_producto),
    );
END
GO

-- ==============================
-- 9. CLIENTE
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Cliente')
BEGIN
    CREATE TABLE ct.Cliente (
        id_cliente INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(100),
        apellido VARCHAR(100),
        telefono VARCHAR(20),
        direccion VARCHAR(100),
		tipo VARCHAR(100),

		CONSTRAINT CK_tipo_cliente
			CHECK (tipo IN ('registrado','consumidor final')),
    );
END
GO


-- ==============================
-- 10. CAPACITADOR
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Capacitador')
BEGIN
    CREATE TABLE ct.Capacitador (
        id_capacitador INT IDENTITY(1,1) PRIMARY KEY,
        nombre VARCHAR(100) NOT NULL,
        apellido VARCHAR(100) NOT NULL
    );
END
GO


-- ==============================
-- 11. CERTIFICADO
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Certificado')
BEGIN
    CREATE TABLE ct.Certificado (
        id_certificado INT IDENTITY(1,1) PRIMARY KEY,
        id_capacitador INT NOT NULL,
        fecha_capacitacion DATE NOT NULL,
        FOREIGN KEY (id_capacitador) REFERENCES ct.Capacitador(id_capacitador)
    );
END
GO

-- ==============================
-- 12. VENDEDOR
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Vendedor')
BEGIN
    CREATE TABLE ct.Vendedor (
        id_vendedor INT NOT NULL,
        nombre VARCHAR(100) NOT NULL,
        apellido VARCHAR(100) NOT NULL,
        id_sucursal INT NOT NULL,
		id_certificado INT NOT NULL,
		CONSTRAINT PK_vendedor 
			PRIMARY KEY (id_vendedor, id_sucursal),
        FOREIGN KEY (id_sucursal) REFERENCES ct.Sucursal(id_sucursal),
		FOREIGN KEY (id_certificado) REFERENCES ct.Certificado(id_certificado)

    );
END
GO



-- ==============================
-- 13. VENTA
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Venta')
BEGIN
    CREATE TABLE ct.Venta (
        id_venta INT IDENTITY(1,1) PRIMARY KEY,
        fecha DATETIME NOT NULL,
        modalidad VARCHAR(50) NOT NULL,
        canal VARCHAR(50) NOT NULL,
        id_vendedor INT NOT NULL,
		id_sucursal INT NOT NULL,
        id_cliente INT NULL,

		CONSTRAINT CK_modalidad_venta
			CHECK (modalidad IN ('presencial','domicilio')),
		CONSTRAINT CK_canal_venta
			CHECK (modalidad IN ('propio','plataforma')),
        FOREIGN KEY (id_vendedor, id_sucursal) REFERENCES ct.Vendedor(id_vendedor, id_sucursal),
		FOREIGN KEY (id_sucursal) REFERENCES ct.Sucursal(id_sucursal),
        FOREIGN KEY (id_cliente) REFERENCES ct.Cliente(id_cliente)
    );
END
GO

-- ==============================
-- 14. DETALLE_VENTA
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'DetalleVenta')
BEGIN
    CREATE TABLE ct.DetalleVenta (
    id_venta INT NOT NULL,
    id_lote INT NOT NULL,
	id_producto INT NOT NULL,
    cantidad INT NOT NULL,
    precio_unitario DECIMAL(10,2) NOT NULL,

    CONSTRAINT PK_DetalleVenta 
        PRIMARY KEY (id_venta),

    CONSTRAINT FK_DetalleVenta_Venta
        FOREIGN KEY (id_venta) REFERENCES ct.Venta(id_venta),

    FOREIGN KEY (id_lote, id_producto)
		REFERENCES ct.Lote(id_lote, id_producto)
);
END
GO



