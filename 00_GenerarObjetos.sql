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
-- CATEGORIA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Categoria')
BEGIN
    CREATE TABLE ct.Categoria (
        id_categoria INT PRIMARY KEY,
        nombre VARCHAR(50) NOT NULL,
        margen_ganancia DECIMAL(5,2)
    );
END
GO

-- TEMPORADA
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Temporada')
BEGIN
    CREATE TABLE ct.Temporada (
        id_temporada INT PRIMARY KEY,
        fecha_comienzo DATE,
        fecha_fin DATE
    );
END
GO

-- PROVEEDOR
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Proveedor')
BEGIN
    CREATE TABLE ct.Proveedor (
        id_proveedor INT PRIMARY KEY,
        nya_prov VARCHAR(100) NOT NULL
    );
END
GO

-- CAPACITADOR
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Capacitador')
BEGIN
    CREATE TABLE ct.Capacitador (
        id_capacitador INT PRIMARY KEY,
        nya_capacitador VARCHAR(100) NOT NULL
    );
END
GO

-- SUCURSAL
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Sucursal')
BEGIN
    CREATE TABLE ct.Sucursal (
        id_sucursal INT PRIMARY KEY,
        ubicacion VARCHAR(100)
    );
END
GO

-- CLIENTE
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Cliente')
BEGIN
    CREATE TABLE ct.Cliente (
        id_cliente INT PRIMARY KEY,
        tipo VARCHAR(50) -- registrado/consumidor final
    );
END
GO

-- VENDEDOR
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Vendedor')
BEGIN
    CREATE TABLE ct.Vendedor (
        id_vendedor INT PRIMARY KEY,
        id_sucursal INT FOREIGN KEY REFERENCES ct.Sucursal(id_sucursal)
    );
END
GO

-- CERTIFICADO
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

-- PRODUCTO
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

-- STOCK
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'Stock')
BEGIN
    CREATE TABLE ct.Stock (
        id_stock INT PRIMARY KEY,
        id_sucursal INT FOREIGN KEY REFERENCES ct.Sucursal(id_sucursal),
        id_producto INT FOREIGN KEY REFERENCES ct.Producto(id_producto)
    );
END
GO

-- LISTA DE PRECIO
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

-- LOTE
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

-- VENTA
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

-- DETALLE VENTA
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

-- Logs errores de proveedores al generar los archivos
IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES 
               WHERE TABLE_SCHEMA = 'ct' AND TABLE_NAME = 'LogErroresProveedores')
BEGIN
    CREATE TABLE ct.LogErroresProveedores (
        Id_Log INT IDENTITY(1,1) PRIMARY KEY,
        Id_Proveedor INT NOT NULL FOREIGN KEY REFERENCES ct.Proveedor(Id_Proveedor),
        Error_Desc VARCHAR(255) NOT NULL,
        FechaRegistro DATETIME NOT NULL DEFAULT GETDATE(),
    );
END
GO


-- ==========  CREACION DE SPs  =============
-- Importar EXCEL listas de precios de proveedores, logear errores y corregir los datos
CREATE PROCEDURE ct.spImportarPreciosExcel_Temp
    @RutaArchivo VARCHAR(255),
    @IdProveedor INT
AS
BEGIN
    -- Tabla temporal
    CREATE TABLE #PreciosTemp (
        Id_Producto VARCHAR(50),
        Costo VARCHAR(50),
        Fecha VARCHAR(50)
    );

    -- Carga desde Excel
    BEGIN TRY
        INSERT INTO #PreciosTemp (Id_Producto, Costo, Fecha)
        SELECT Id_Producto, Costo, Fecha
        FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
            'Excel 12.0;Database=' + @RutaArchivo + ';HDR=YES',
            'SELECT Id_Producto, Costo, Fecha FROM [Hoja1$]');
    END TRY
    BEGIN CATCH
        INSERT INTO ct.LogErroresProveedores (Id_Proveedor, Error_Desc)
        VALUES (@IdProveedor, ERROR_MESSAGE(), CONCAT('Archivo Excel: ', @RutaArchivo));
        RETURN;
    END CATCH;

    -- Corrección de datos
    CREATE TABLE #PreciosValidados (
        Id_Producto INT,
        Costo DECIMAL(10,2),
        Fecha DATE
    );

    INSERT INTO #PreciosValidados
    SELECT TRY_CAST(Id_Producto AS INT),
           TRY_CAST(Costo AS DECIMAL(10,2)),
           TRY_CAST(Fecha AS DATE)
    FROM #PreciosTemp
    WHERE TRY_CAST(Id_Producto AS INT) IS NOT NULL
      AND TRY_CAST(Costo AS DECIMAL(10,2)) IS NOT NULL
      AND TRY_CAST(Fecha AS DATE) IS NOT NULL;

    -- Registrar errores de validación
    INSERT INTO ct.LogErroresProveedor (Id_Proveedor, ErrorDescripcion, FilaOriginal)
    SELECT @IdProveedor, 'Error de validación',
           CONCAT('Fila original -> Producto:', Id_Producto, ', Costo:', Costo, ', Fecha:', Fecha)
    FROM #PreciosTemp
    WHERE TRY_CAST(Id_Producto AS INT) IS NULL
       OR TRY_CAST(Costo AS DECIMAL(10,2)) IS NULL
       OR TRY_CAST(Fecha AS DATE) IS NULL;

    -- Insertar datos corregidos
    INSERT INTO ct.Precios_Proveedor_Corregido (Id_Producto, Costo, Fecha, Id_Proveedor)
    SELECT Id_Producto, Costo, Fecha, @IdProveedor
    FROM #PreciosValidados;
END
GO


-- Importal CSV listas de precios de proveedores, logear errores y corregir los datos

CREATE PROCEDURE ct.spImportarPreciosCSV_Temp
    @RutaArchivo VARCHAR(255),
    @IdProveedor INT
AS
BEGIN
    CREATE TABLE #PreciosTemp (
        Id_Producto VARCHAR(50),
        Costo VARCHAR(50),
        Fecha VARCHAR(50)
    );

    BEGIN TRY
        BULK INSERT #PreciosTemp
        FROM @RutaArchivo
        WITH (
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            FIRSTROW = 2
        );
    END TRY
    BEGIN CATCH
        INSERT INTO ct.LogErroresProveedor (Id_Proveedor, ErrorDescripcion, FilaOriginal)
        VALUES (@IdProveedor, ERROR_MESSAGE(), CONCAT('Archivo CSV: ', @RutaArchivo));
        RETURN;
    END CATCH;

    -- Validación y corrección
    CREATE TABLE #PreciosValidados (
        Id_Producto INT,
        Costo DECIMAL(10,2),
        Fecha DATE
    );

    INSERT INTO #PreciosValidados
    SELECT TRY_CAST(Id_Producto AS INT),
           TRY_CAST(Costo AS DECIMAL(10,2)),
           TRY_CAST(Fecha AS DATE)
    FROM #PreciosTemp
    WHERE TRY_CAST(Id_Producto AS INT) IS NOT NULL
      AND TRY_CAST(Costo AS DECIMAL(10,2)) IS NOT NULL
      AND TRY_CAST(Fecha AS DATE) IS NOT NULL;

    INSERT INTO ct.LogErroresProveedores(Id_Proveedor, Error_Desc)
    SELECT @IdProveedor, 'Error de validación',
           CONCAT('Fila original -> Producto:', Id_Producto, ', Costo:', Costo, ', Fecha:', Fecha)
    FROM #PreciosTemp
    WHERE TRY_CAST(Id_Producto AS INT) IS NULL
       OR TRY_CAST(Costo AS DECIMAL(10,2)) IS NULL
       OR TRY_CAST(Fecha AS DATE) IS NULL;

    INSERT INTO ct.Precios_Proveedor_Corregido (Id_Producto, Costo, Fecha, Id_Proveedor)
    SELECT Id_Producto, Costo, Fecha, @IdProveedor
    FROM #PreciosValidados;
END
GO

-- Importal TEXTO PLANO listas de precios de proveedores, logear errores y corregir los datos

CREATE PROCEDURE ct.spImportarPreciosTXT_Temp
    @RutaArchivo VARCHAR(255),
    @IdProveedor INT
AS
BEGIN
    CREATE TABLE #PreciosTemp (
        Id_Producto VARCHAR(50),
        Costo VARCHAR(50),
        Fecha VARCHAR(50)
    );

    BEGIN TRY
        BULK INSERT #PreciosTemp
        FROM @RutaArchivo
        WITH (
            FIELDTERMINATOR = '|',   -- suponemos que el texto usa |
            ROWTERMINATOR = '\n',
            FIRSTROW = 2
        );
    END TRY
    BEGIN CATCH
        INSERT INTO ct.LogErroresProveedores (Id_Proveedor, Error_Desc)
        VALUES (@IdProveedor, ERROR_MESSAGE(), CONCAT('Archivo TXT: ', @RutaArchivo));
        RETURN;
    END CATCH;

    -- Validación y corrección
    CREATE TABLE #PreciosValidados (
        Id_Producto INT,
        Costo DECIMAL(10,2),
        Fecha DATE
    );

    INSERT INTO #PreciosValidados
    SELECT TRY_CAST(Id_Producto AS INT),
           TRY_CAST(Costo AS DECIMAL(10,2)),
           TRY_CAST(Fecha AS DATE)
    FROM #PreciosTemp
    WHERE TRY_CAST(Id_Producto AS INT) IS NOT NULL
      AND TRY_CAST(Costo AS DECIMAL(10,2)) IS NOT NULL
      AND TRY_CAST(Fecha AS DATE) IS NOT NULL;

    INSERT INTO ct.LogErroresProveedores (Id_Proveedor, Error_Desc)
    SELECT @IdProveedor, 'Error de validación',
           CONCAT('Fila original -> Producto:', Id_Producto, ', Costo:', Costo, ', Fecha:', Fecha)
    FROM #PreciosTemp
    WHERE TRY_CAST(Id_Producto AS INT) IS NULL
       OR TRY_CAST(Costo AS DECIMAL(10,2)) IS NULL
       OR TRY_CAST(Fecha AS DATE) IS NULL;

    INSERT INTO ct.Precios_Proveedor_Corregido (Id_Producto, Costo, Fecha, Id_Proveedor)
    SELECT Id_Producto, Costo, Fecha, @IdProveedor
    FROM #PreciosValidados;
END
GO
