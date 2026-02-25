
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

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'staging') -- CARGAR SP PARA STAGING
BEGIN
	EXEC('CREATE SCHEMA staging')
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
        direccion VARCHAR(200) NOT NULL
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
            FOREIGN KEY (id_sucursal) REFERENCES ct.Sucursal(id_sucursal)
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
        FOREIGN KEY (id_producto) REFERENCES ct.Producto(id_producto)
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
			CHECK (tipo IN ('registrado','consumidor final'))
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
		numero_registro VARCHAR(50) NOT NULL UNIQUE,  -- clave natural del padrón
		nombre VARCHAR(150) NOT NULL,
		apellido VARCHAR(150) NOT NULL,
		telefono VARCHAR(50) NULL,
		mail VARCHAR(150) NULL,
		fecha_alta DATETIME DEFAULT GETDATE()
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
		fecha_vencimiento DATE NULL,
		numero_certificado VARCHAR(100) NULL,
		fecha_registro DATETIME DEFAULT GETDATE(),

		CONSTRAINT FK_Certificado_Capacitador
			FOREIGN KEY (id_capacitador)
			REFERENCES ct.Capacitador(id_capacitador),

		CONSTRAINT CK_Fecha_Vencimiento
			CHECK (fecha_vencimiento IS NULL 
				   OR fecha_vencimiento >= fecha_capacitacion)
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
			CHECK (canal IN ('propio','plataforma')),
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

-- ==============================
-- 15. MERMA
--Esta es la tabla productiva final. Es donde queda el histórico real.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Merma')
BEGIN
    CREATE TABLE ct.Merma (
        id_merma INT IDENTITY PRIMARY KEY,
        id_producto INT NOT NULL,
        id_sucursal INT NOT NULL,
        fecha DATE NOT NULL,
        cantidad INT NOT NULL,
        FOREIGN KEY (id_producto) REFERENCES ct.Producto(id_producto),
        FOREIGN KEY (id_sucursal) REFERENCES ct.Sucursal(id_sucursal),
        CONSTRAINT UQ_merma UNIQUE (id_producto, id_sucursal, fecha)
    );
END
GO

-- ==============================
-- 16. Staging MERMA
--Es la zona sucia. Aca entra el archivo con BULK INSERT.No tiene claves, no tiene restricciones.Es temporal.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'MermasRaw')
BEGIN
    CREATE TABLE staging.MermasRaw (
        fecha VARCHAR(50),
        producto VARCHAR(200),
        cantidad VARCHAR(50),
        sucursal VARCHAR(200)
    );
END
GO

-- ==============================
-- 17. Staging Errores MERMA
--Registra errores detectados durante el procesamiento.No afecta la tabla productiva.
-- ==============================

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'ErroresMermas')
BEGIN
	   CREATE TABLE staging.ErroresMermas (
		fecha DATETIME DEFAULT GETDATE(),
		descripcion VARCHAR(500),
		fila_producto VARCHAR(200),
		fila_sucursal VARCHAR(200)
	);
END
GO

-- ==============================
-- 18. Staging LogImportacionMermas
--Registra el log de las importaciones.
-- ==============================

IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'LogImportacionMermas')
BEGIN
    CREATE TABLE staging.LogImportacionMermas(
        id_log INT IDENTITY PRIMARY KEY,
        fecha_importacion DATETIME DEFAULT GETDATE(),
        registros_staging INT,
        registros_insertados INT,
        registros_error INT
    );
END
GO


-- ==============================
-- 19. Estimaciones agricolas
--Esta es la tabla productiva final. Es donde queda el histórico real.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'EstimacionAgricola')
BEGIN
    CREATE TABLE ct.EstimacionAgricola (
        id_estimacion INT IDENTITY PRIMARY KEY,
        cultivo VARCHAR(100) NOT NULL,
        campania VARCHAR(20) NOT NULL,
        municipio_id INT NOT NULL,
        municipio_nombre VARCHAR(150) NOT NULL,
        superficie_sembrada DECIMAL(18,2),
        superficie_cosechada DECIMAL(18,2),
        produccion DECIMAL(18,2),
        rendimiento DECIMAL(18,2),

        CONSTRAINT UQ_estimacion 
            UNIQUE (cultivo, campania, municipio_id)
    );
END
GO
-- ==============================
-- 20. Staging EstimacionesRaw
--Es la zona sucia. Aca entra el archivo con BULK INSERT.No tiene claves, no tiene restricciones.Es temporal.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'EstimacionesRaw')
BEGIN
    CREATE TABLE staging.EstimacionesRaw (
        cultivo VARCHAR(200),
        campania VARCHAR(50),
        municipio_id VARCHAR(50),
        municipio_nombre VARCHAR(200),
        superficie_sembrada VARCHAR(50),
        superficie_cosechada VARCHAR(50),
        produccion VARCHAR(50),
        rendimiento VARCHAR(50)
    );
END
GO


-- ==============================
-- 17. Staging Errores Estimaciones
--Registra errores detectados durante el procesamiento.No afecta la tabla productiva.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'ErroresEstimaciones')
BEGIN
    CREATE TABLE staging.ErroresEstimaciones (
        fecha DATETIME DEFAULT GETDATE(),
        descripcion VARCHAR(500),
        cultivo VARCHAR(200),
        campania VARCHAR(50),
        municipio VARCHAR(200)
    );
END
GO

-- ==============================
-- 20. Staging LogImportacionEstimaciones
--Es la zona sucia. Aca entra el archivo con BULK INSERT.No tiene claves, no tiene restricciones.Es temporal.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'LogImportacionEstimaciones')
BEGIN
    CREATE TABLE staging.LogImportacionEstimaciones(
        id_log INT IDENTITY PRIMARY KEY,
        fecha_importacion DATETIME DEFAULT GETDATE(),
        registros_staging INT,
        registros_actualizados INT,
        registros_insertados INT,
        registros_error INT
    );
END
GO


-- ==============================
-- 20. Staging CapacitadoresRaw
--Es la zona sucia. Aca entra el archivo con BULK INSERT.No tiene claves, no tiene restricciones.Es temporal.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'CapacitadoresRaw')
BEGIN
    CREATE TABLE staging.CapacitadoresRaw (
		numero_registro VARCHAR(100),
		nombre_completo VARCHAR(200),
		telefono VARCHAR(50),
		mail VARCHAR(200)
	);
END
GO

-- ==============================
-- 17. Staging Errores Capacitadores
--Registra errores detectados durante el procesamiento.No afecta la tabla productiva.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'ErroresCapacitadores')
BEGIN
    CREATE TABLE staging.ErroresCapacitadores (
		fecha DATETIME DEFAULT GETDATE(),
		descripcion VARCHAR(500),
		numero_registro VARCHAR(100)
	);
END
GO

-- ==============================
-- 20. Staging LogImportacionCapacitadores
--Es la zona sucia. Aca entra el archivo con BULK INSERT.No tiene claves, no tiene restricciones.Es temporal.
-- ==============================
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'LogImportacionCapacitadores')
BEGIN
    CREATE TABLE staging.LogImportacionCapacitadores(
		id_log INT IDENTITY PRIMARY KEY,
		fecha_importacion DATETIME DEFAULT GETDATE(),
		registros_staging INT,
		registros_actualizados INT,
		registros_insertados INT,
		registros_error INT
	);
END
GO

-- ==============================
-- 21. PRECIO MAYORISTA (FINAL)
-- ==============================


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'PrecioMayorista')
BEGIN
    CREATE TABLE ct.PrecioMayorista (
    id_precio INT IDENTITY PRIMARY KEY,

    fecha DATE NOT NULL,
    tipo_producto VARCHAR(20) NOT NULL,  -- fruta / hortaliza

    especie VARCHAR(150) NOT NULL,       -- ESP
    variedad VARCHAR(150) NULL,          -- VAR
    procedencia VARCHAR(150) NULL,       -- PROC
    envase VARCHAR(50) NULL,             -- ENV
    kg VARCHAR(50) NULL,                 -- KG
    calidad VARCHAR(50) NULL,            -- CAL
    tamanio VARCHAR(100) NULL,           -- TAM
    grado VARCHAR(50) NULL,              -- GRADO

    precio_mayorista DECIMAL(18,2) NULL,         -- MA
    precio_modal DECIMAL(18,2) NULL,             -- MO
    precio_minimo DECIMAL(18,2) NULL,            -- MI

    precio_mayorista_kg DECIMAL(18,2) NULL,      -- MAPK
    precio_modal_kg DECIMAL(18,2) NULL,          -- MOPK
    precio_minimo_kg DECIMAL(18,2) NULL,         -- MIPK

    --CONSTRAINT UQ_precio
    --    UNIQUE (fecha, tipo_producto, especie, variedad, procedencia, tamanio, grado)
);
END
GO


-- ==============================
-- 22. Staging PreciosRaw
-- ==============================


IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'staging' AND TABLE_NAME = 'PreciosRaw')
BEGIN
    CREATE TABLE staging.PreciosRaw (
		ESP VARCHAR(200),
		VAR VARCHAR(200),
		PROCEDENCIA  VARCHAR(200),
		ENV VARCHAR(50),
		KG VARCHAR(50),
		CAL VARCHAR(50),
		TAM VARCHAR(100),
		GRADO VARCHAR(50),

		MA VARCHAR(50),
		MO VARCHAR(50),
		MI VARCHAR(50),

		MAPK VARCHAR(50),
		MOPK VARCHAR(50),
		MIPK VARCHAR(50)
	);
END
GO

-- ==============================
-- 23. Staging ErroresPrecios
-- ==============================
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'staging' 
    AND TABLE_NAME = 'ErroresPrecios'
)
BEGIN
    CREATE TABLE staging.ErroresPrecios (
        fecha DATETIME DEFAULT GETDATE(),
        descripcion VARCHAR(500),
        especie VARCHAR(200),
        variedad VARCHAR(200)
    );
END
GO


-- ==============================
-- 24. Staging LogImportacionPrecios
-- ==============================
IF NOT EXISTS (
    SELECT * FROM INFORMATION_SCHEMA.TABLES 
    WHERE TABLE_SCHEMA = 'staging' 
    AND TABLE_NAME = 'LogImportacionPrecios'
)
BEGIN
    CREATE TABLE staging.LogImportacionPrecios(
        id_log INT IDENTITY PRIMARY KEY,
        fecha_importacion DATETIME DEFAULT GETDATE(),
        fecha_archivo DATE,
        tipo_producto VARCHAR(20),
        registros_staging INT,
        registros_actualizados INT,
        registros_insertados INT,
        registros_error INT
    );
END
GO


