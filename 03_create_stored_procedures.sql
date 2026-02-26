/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
    Componentes del grupo:
        - Leonel Cespedes
        - Luciana Franchetti

    Descripción:
    Creación de Stored Procedures para inserción,
    modificación y eliminación de datos con validaciones.
*/

USE Com2343;
GO

---------------------------------------------------------------------
-- BORRAR TODOS LOS STORED PROCEDURES DEL SCHEMA CSP
---------------------------------------------------------------------

DECLARE @sql NVARCHAR(MAX) = '';

SELECT @sql += 'DROP PROCEDURE csp.' + name + ';' + CHAR(13)
FROM sys.procedures
WHERE SCHEMA_NAME(schema_id) = 'csp';

EXEC sp_executesql @sql;
GO

/*********************************************************************
**********************  STORED PROCEDURES  ***************************
*********************************************************************/

/*
=========================================================
SP: csp.AltaSucursal
Descripción:
Permite registrar una nueva sucursal.

Validaciones:
- Nombre obligatorio
- Nombre mínimo 3 caracteres
- Dirección obligatoria
- Dirección mínimo 5 caracteres
- No permitir sucursales con mismo nombre
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaSucursal
    @nombre VARCHAR(100),
    @direccion VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre es obligatorio.' + CHAR(13);

    IF (LEN(@nombre) < 3)
        SET @errores += 'El nombre debe tener al menos 3 caracteres.' + CHAR(13);

    IF (@direccion IS NULL OR LTRIM(RTRIM(@direccion)) = '')
        SET @errores += 'La dirección es obligatoria.' + CHAR(13);

    IF (LEN(@direccion) < 5)
        SET @errores += 'La dirección debe tener al menos 5 caracteres.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Sucursal WHERE nombre = @nombre)
        SET @errores += 'Ya existe una sucursal con ese nombre.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Sucursal(nombre, direccion)
    VALUES(@nombre, @direccion);
END
GO


/*
=========================================================
SP: csp.ModificarSucursal
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.ModificarSucursal
    @id_sucursal INT,
    @nombre VARCHAR(100),
    @direccion VARCHAR(200)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Sucursal WHERE id_sucursal = @id_sucursal)
        SET @errores += 'La sucursal indicada no existe.' + CHAR(13);

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre es obligatorio.' + CHAR(13);

    IF (@direccion IS NULL OR LTRIM(RTRIM(@direccion)) = '')
        SET @errores += 'La dirección es obligatoria.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Sucursal 
               WHERE nombre = @nombre 
               AND id_sucursal <> @id_sucursal)
        SET @errores += 'Ya existe otra sucursal con ese nombre.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    UPDATE ct.Sucursal
    SET nombre = @nombre,
        direccion = @direccion
    WHERE id_sucursal = @id_sucursal;
END
GO


/*
=========================================================
SP: csp.BajaSucursal
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaSucursal
    @id_sucursal INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Sucursal WHERE id_sucursal = @id_sucursal)
        SET @errores += 'La sucursal indicada no existe.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Stock WHERE id_sucursal = @id_sucursal)
        SET @errores += 'No se puede eliminar la sucursal porque posee stock asociado.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    DELETE FROM ct.Sucursal
    WHERE id_sucursal = @id_sucursal;
END
GO


/*
=========================================================
SP: csp.AltaStock
Descripción:
Permite registrar el stock mínimo asociado a una sucursal.

Validaciones:
- La sucursal debe existir
- Stock mínimo no puede ser negativo
- Fecha no puede ser futura
- No permitir más de un registro de stock por sucursal
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaStock
    @id_sucursal INT,
    @stock_minimo INT,
    @fecha_ultima_actualizacion DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Sucursal WHERE id_sucursal = @id_sucursal)
        SET @errores += 'La sucursal indicada no existe.' + CHAR(13);

    IF (@stock_minimo < 0)
        SET @errores += 'El stock mínimo no puede ser negativo.' + CHAR(13);

    IF (@fecha_ultima_actualizacion > GETDATE())
        SET @errores += 'La fecha no puede ser futura.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Stock WHERE id_sucursal = @id_sucursal)
        SET @errores += 'Ya existe stock para esa sucursal.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Stock(id_sucursal, stock_minimo, fecha_ultima_actualizacion)
    VALUES(@id_sucursal, @stock_minimo, @fecha_ultima_actualizacion);
END
GO


/*
=========================================================
SP: csp.ModificarStock
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.ModificarStock
    @id_stock INT,
    @stock_minimo INT,
    @fecha_ultima_actualizacion DATETIME
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Stock WHERE id_stock = @id_stock)
        SET @errores += 'El registro de stock indicado no existe.' + CHAR(13);

    IF (@stock_minimo < 0)
        SET @errores += 'El stock mínimo no puede ser negativo.' + CHAR(13);

    IF (@fecha_ultima_actualizacion > GETDATE())
        SET @errores += 'La fecha no puede ser futura.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    UPDATE ct.Stock
    SET stock_minimo = @stock_minimo,
        fecha_ultima_actualizacion = @fecha_ultima_actualizacion
    WHERE id_stock = @id_stock;
END
GO


/*
=========================================================
SP: csp.BajaStock
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaStock
    @id_stock INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Stock WHERE id_stock = @id_stock)
        SET @errores += 'El registro de stock indicado no existe.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    DELETE FROM ct.Stock
    WHERE id_stock = @id_stock;
END
GO

/*
=========================================================
SP: csp.AltaTemporada
Descripción:
Permite registrar una nueva temporada.

Validaciones:
- Nombre obligatorio
- Descripción obligatoria
- Fecha inicio < fecha fin
- No permitir temporadas con mismo nombre
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaTemporada
    @nombre VARCHAR(50),
    @descripcion VARCHAR(50),
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre de la temporada es obligatorio.' + CHAR(13);

    IF (@descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = '')
        SET @errores += 'La descripción es obligatoria.' + CHAR(13);

    IF (@fecha_inicio >= @fecha_fin)
        SET @errores += 'La fecha de inicio debe ser menor a la fecha de fin.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Temporada WHERE nombre = @nombre)
        SET @errores += 'Ya existe una temporada con ese nombre.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Temporada(nombre, descripcion, fecha_inicio, fecha_fin)
    VALUES(@nombre, @descripcion, @fecha_inicio, @fecha_fin);
END
GO

/*
=========================================================
SP: csp.ModificarTemporada
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.ModificarTemporada
    @id_temporada INT,
    @nombre VARCHAR(50),
    @descripcion VARCHAR(50),
    @fecha_inicio DATE,
    @fecha_fin DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Temporada WHERE id_temporada = @id_temporada)
        SET @errores += 'La temporada indicada no existe.' + CHAR(13);

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre es obligatorio.' + CHAR(13);

    IF (@descripcion IS NULL OR LTRIM(RTRIM(@descripcion)) = '')
        SET @errores += 'La descripción es obligatoria.' + CHAR(13);

    IF (@fecha_inicio >= @fecha_fin)
        SET @errores += 'La fecha de inicio debe ser menor a la fecha de fin.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Temporada 
               WHERE nombre = @nombre 
               AND id_temporada <> @id_temporada)
        SET @errores += 'Ya existe otra temporada con ese nombre.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    UPDATE ct.Temporada
    SET nombre = @nombre,
        descripcion = @descripcion,
        fecha_inicio = @fecha_inicio,
        fecha_fin = @fecha_fin
    WHERE id_temporada = @id_temporada;
END
GO


/*
=========================================================
SP: csp.BajaTemporada
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaTemporada
    @id_temporada INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Temporada WHERE id_temporada = @id_temporada)
        SET @errores += 'La temporada indicada no existe.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Producto WHERE id_temporada = @id_temporada)
        SET @errores += 'No se puede eliminar la temporada porque está asociada a productos.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    DELETE FROM ct.Temporada
    WHERE id_temporada = @id_temporada;
END
GO

/*
=========================================================
SP: csp.AltaCategoria
Descripción:
Permite registrar una nueva categoría de productos.

Validaciones:
- Nombre obligatorio
- Nombre mínimo 3 caracteres
- Margen de ganancia mayor a 0
- No permitir categorías con mismo nombre
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaCategoria
    @nombre VARCHAR(50),
    @margen_ganancia DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre de la categoría es obligatorio.' + CHAR(13);

    IF (@margen_ganancia <= 0)
        SET @errores += 'El margen de ganancia debe ser mayor a 0.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Categoria WHERE nombre = @nombre)
        SET @errores += 'Ya existe una categoría con ese nombre.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Categoria(nombre, margen_ganancia)
    VALUES(@nombre, @margen_ganancia);
END
GO

/*
=========================================================
SP: csp.ModificarCategoria
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.ModificarCategoria
    @id_categoria INT,
    @nombre VARCHAR(50),
    @margen_ganancia DECIMAL(5,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Categoria WHERE id_categoria = @id_categoria)
        SET @errores += 'La categoría indicada no existe.' + CHAR(13);

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre es obligatorio.' + CHAR(13);

    IF (@margen_ganancia <= 0)
        SET @errores += 'El margen de ganancia debe ser mayor a 0.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Categoria 
               WHERE nombre = @nombre 
               AND id_categoria <> @id_categoria)
        SET @errores += 'Ya existe otra categoría con ese nombre.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    UPDATE ct.Categoria
    SET nombre = @nombre,
        margen_ganancia = @margen_ganancia
    WHERE id_categoria = @id_categoria;
END
GO

/*
=========================================================
SP: csp.BajaCategoria
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaCategoria
    @id_categoria INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Categoria WHERE id_categoria = @id_categoria)
        SET @errores += 'La categoría indicada no existe.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Producto WHERE id_categoria = @id_categoria)
        SET @errores += 'No se puede eliminar la categoría porque está asociada a productos.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    DELETE FROM ct.Categoria
    WHERE id_categoria = @id_categoria;
END
GO


/*
=========================================================
SP: csp.AltaProveedor
Descripción:
Permite registrar un nuevo proveedor.

Validaciones:
- Nombre obligatorio
- Apellido obligatorio
- CUIT obligatorio
- No permitir proveedores con mismo CUIT
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaProveedor
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @telefono VARCHAR(20),
    @cuit VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre es obligatorio.' + CHAR(13);

    IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
        SET @errores += 'El apellido es obligatorio.' + CHAR(13);

    IF (@cuit IS NULL OR LTRIM(RTRIM(@cuit)) = '')
        SET @errores += 'El CUIT es obligatorio.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Proveedor WHERE cuit = @cuit)
        SET @errores += 'Ya existe un proveedor con ese CUIT.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Proveedor(nombre, apellido, telefono, cuit)
    VALUES(@nombre, @apellido, @telefono, @cuit);
END
GO

/*
=========================================================
SP: csp.ModificarProveedor
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.ModificarProveedor
    @id_proveedor INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @telefono VARCHAR(20),
    @cuit VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Proveedor WHERE id_proveedor = @id_proveedor)
        SET @errores += 'El proveedor indicado no existe.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Proveedor 
               WHERE cuit = @cuit 
               AND id_proveedor <> @id_proveedor)
        SET @errores += 'Ya existe otro proveedor con ese CUIT.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    UPDATE ct.Proveedor
    SET nombre = @nombre,
        apellido = @apellido,
        telefono = @telefono,
        cuit = @cuit
    WHERE id_proveedor = @id_proveedor;
END
GO


/*
=========================================================
SP: csp.BajaProveedor
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaProveedor
    @id_proveedor INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Proveedor WHERE id_proveedor = @id_proveedor)
        SET @errores += 'El proveedor indicado no existe.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Producto WHERE id_proveedor = @id_proveedor)
        SET @errores += 'No se puede eliminar el proveedor porque posee productos asociados.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    DELETE FROM ct.Proveedor WHERE id_proveedor = @id_proveedor;
END
GO

/*
=========================================================
SP: csp.AltaProducto
Descripción:
Permite registrar un nuevo producto.

Validaciones:
- Nombre obligatorio
- Vida útil mayor a 0
- Categoria debe existir
- Si se informa proveedor/temporada/stock deben existir
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaProducto
    @nombre VARCHAR(50),
    @descripcion VARCHAR(100),
    @forma_comercializacion VARCHAR(50),
    @tipo_producto_agricola VARCHAR(50),
    @vida_util INT,
    @id_categoria INT,
    @id_stock INT = NULL,
    @id_temporada INT = NULL,
    @id_proveedor INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre es obligatorio.' + CHAR(13);

    IF (@vida_util <= 0)
        SET @errores += 'La vida útil debe ser mayor a 0.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ct.Categoria WHERE id_categoria = @id_categoria)
        SET @errores += 'La categoría indicada no existe.' + CHAR(13);

    IF (@id_proveedor IS NOT NULL AND 
        NOT EXISTS (SELECT 1 FROM ct.Proveedor WHERE id_proveedor = @id_proveedor))
        SET @errores += 'El proveedor indicado no existe.' + CHAR(13);

    IF (@id_temporada IS NOT NULL AND 
        NOT EXISTS (SELECT 1 FROM ct.Temporada WHERE id_temporada = @id_temporada))
        SET @errores += 'La temporada indicada no existe.' + CHAR(13);

    IF (@id_stock IS NOT NULL AND 
        NOT EXISTS (SELECT 1 FROM ct.Stock WHERE id_stock = @id_stock))
        SET @errores += 'El stock indicado no existe.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Producto
    (nombre, descripcion, forma_comercializacion, tipo_producto_agricola,
     vida_util, id_categoria, id_stock, id_temporada, id_proveedor)
    VALUES
    (@nombre, @descripcion, @forma_comercializacion, @tipo_producto_agricola,
     @vida_util, @id_categoria, @id_stock, @id_temporada, @id_proveedor);
END
GO


CREATE OR ALTER PROCEDURE csp.BajaProducto
    @id_producto INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Producto WHERE id_producto = @id_producto)
    BEGIN
        RAISERROR('El producto no existe.',16,1);
        RETURN;
    END;

    DELETE FROM ct.Producto WHERE id_producto = @id_producto;
END
GO

/*
=========================================================
SP: csp.AltaListaPrecio
Descripción:
Permite registrar una lista de precio asociada
a un producto y proveedor.

Validaciones:
- Producto debe existir
- Proveedor debe existir
- No permitir duplicados (PK compuesta)
- Formato debe ser 'json' o 'csv'
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaListaPrecio
    @id_listaPrecio INT,
    @id_producto INT,
    @id_proveedor INT,
    @formato VARCHAR(10)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Producto WHERE id_producto = @id_producto)
        SET @errores += 'El producto no existe.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ct.Proveedor WHERE id_proveedor = @id_proveedor)
        SET @errores += 'El proveedor no existe.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.ListaPrecio 
               WHERE id_producto = @id_producto 
               AND id_proveedor = @id_proveedor 
               AND id_listaPrecio = @id_listaPrecio)
        SET @errores += 'La lista de precio ya existe.' + CHAR(13);

    IF (@formato NOT IN ('json','csv'))
        SET @errores += 'Formato inválido.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.ListaPrecio
    VALUES (@id_listaPrecio, @id_producto, @id_proveedor, @formato);
END
GO


/*
=========================================================
SP: csp.BajaListaPrecio
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaListaPrecio
    @id_listaPrecio INT,
    @id_producto INT,
    @id_proveedor INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.ListaPrecio 
                   WHERE id_listaPrecio = @id_listaPrecio
                   AND id_producto = @id_producto
                   AND id_proveedor = @id_proveedor)
    BEGIN
        RAISERROR('La lista de precio no existe.',16,1);
        RETURN;
    END;

    DELETE FROM ct.ListaPrecio
    WHERE id_listaPrecio = @id_listaPrecio
      AND id_producto = @id_producto
      AND id_proveedor = @id_proveedor;
END
GO


/*
=========================================================
SP: csp.AltaLote
Descripción:
Permite registrar un nuevo lote de producto.

Validaciones:
- Producto debe existir
- Cantidad inicial mayor a 0
- Costo mayor a 0
- Fecha ingreso <= fecha vencimiento
- No permitir duplicado (PK compuesta)
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaLote
    @id_lote INT,
    @id_producto INT,
    @cantidad_inicial INT,
    @costo DECIMAL(10,2),
    @fecha_ingreso DATE,
    @fecha_vencimiento DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Producto WHERE id_producto = @id_producto)
        SET @errores += 'El producto no existe.' + CHAR(13);

    IF (@cantidad_inicial <= 0)
        SET @errores += 'La cantidad debe ser mayor a 0.' + CHAR(13);

    IF (@costo <= 0)
        SET @errores += 'El costo debe ser mayor a 0.' + CHAR(13);

    IF (@fecha_ingreso > @fecha_vencimiento)
        SET @errores += 'La fecha de ingreso no puede ser mayor a la de vencimiento.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Lote 
               WHERE id_lote = @id_lote 
               AND id_producto = @id_producto)
        SET @errores += 'El lote ya existe.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Lote
    VALUES (@id_lote, @id_producto, @cantidad_inicial,
            @costo, @fecha_ingreso, @fecha_vencimiento);
END
GO


CREATE OR ALTER PROCEDURE csp.ModificarLote
    @id_lote INT,
    @id_producto INT,
    @cantidad_inicial INT,
    @costo DECIMAL(10,2),
    @fecha_ingreso DATE,
    @fecha_vencimiento DATE
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Lote 
                   WHERE id_lote = @id_lote 
                   AND id_producto = @id_producto)
    BEGIN
        RAISERROR('El lote no existe.',16,1);
        RETURN;
    END;

    UPDATE ct.Lote
    SET cantidad_inicial = @cantidad_inicial,
        costo = @costo,
        fecha_ingreso = @fecha_ingreso,
        fecha_vencimiento = @fecha_vencimiento
    WHERE id_lote = @id_lote
      AND id_producto = @id_producto;
END
GO


CREATE OR ALTER PROCEDURE csp.BajaLote
    @id_lote INT,
    @id_producto INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Lote 
                   WHERE id_lote = @id_lote 
                   AND id_producto = @id_producto)
    BEGIN
        RAISERROR('El lote no existe.',16,1);
        RETURN;
    END;

    DELETE FROM ct.Lote
    WHERE id_lote = @id_lote
      AND id_producto = @id_producto;
END
GO

/*
=========================================================
SP: csp.AltaCliente
Descripción:
Permite registrar un nuevo cliente.

Validaciones:
- Nombre obligatorio
- Apellido obligatorio
- Tipo debe ser 'registrado' o 'consumidor final'
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaCliente
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @telefono VARCHAR(20),
    @direccion VARCHAR(100),
    @tipo VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre es obligatorio.' + CHAR(13);

    IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
        SET @errores += 'El apellido es obligatorio.' + CHAR(13);

    IF (@tipo NOT IN ('registrado','consumidor final'))
        SET @errores += 'Tipo de cliente inválido.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Cliente(nombre, apellido, telefono, direccion, tipo)
    VALUES(@nombre, @apellido, @telefono, @direccion, @tipo);
END
GO


/*
=========================================================
SP: csp.ModificarCliente
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.ModificarCliente
    @id_cliente INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @telefono VARCHAR(20),
    @direccion VARCHAR(100),
    @tipo VARCHAR(100)
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Cliente WHERE id_cliente = @id_cliente)
    BEGIN
        RAISERROR('El cliente no existe.',16,1);
        RETURN;
    END;

    UPDATE ct.Cliente
    SET nombre = @nombre,
        apellido = @apellido,
        telefono = @telefono,
        direccion = @direccion,
        tipo = @tipo
    WHERE id_cliente = @id_cliente;
END
GO


CREATE OR ALTER PROCEDURE csp.BajaCliente
    @id_cliente INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Cliente WHERE id_cliente = @id_cliente)
    BEGIN
        RAISERROR('El cliente no existe.',16,1);
        RETURN;
    END;

    DELETE FROM ct.Cliente
    WHERE id_cliente = @id_cliente;
END
GO


/*
=========================================================
SP: csp.AltaCapacitador
Descripción:
Permite registrar un nuevo capacitador.

Validaciones:
- Nombre obligatorio
- Apellido obligatorio
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaCapacitador
    @numero_registro VARCHAR(50),
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @telefono VARCHAR(50) = NULL,
    @mail VARCHAR(150) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@numero_registro IS NULL OR LTRIM(RTRIM(@numero_registro)) = '')
        SET @errores += 'El número de registro es obligatorio.' + CHAR(13);

    IF (@nombre IS NULL OR LTRIM(RTRIM(@nombre)) = '')
        SET @errores += 'El nombre es obligatorio.' + CHAR(13);

    IF (@apellido IS NULL OR LTRIM(RTRIM(@apellido)) = '')
        SET @errores += 'El apellido es obligatorio.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Capacitador WHERE numero_registro = @numero_registro)
        SET @errores += 'Ya existe un capacitador con ese número de registro.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Capacitador
    (numero_registro, nombre, apellido, telefono, mail)
    VALUES
    (@numero_registro, @nombre, @apellido, @telefono, @mail);
END
GO


CREATE OR ALTER PROCEDURE csp.ModificarCapacitador
    @id_capacitador INT,
    @numero_registro VARCHAR(50),
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @telefono VARCHAR(50) = NULL,
    @mail VARCHAR(150) = NULL
AS
BEGIN
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Capacitador WHERE id_capacitador = @id_capacitador)
        SET @errores += 'El capacitador no existe.' + CHAR(13);

    IF EXISTS (
        SELECT 1 FROM ct.Capacitador 
        WHERE numero_registro = @numero_registro 
        AND id_capacitador <> @id_capacitador)
        SET @errores += 'Ya existe otro capacitador con ese número de registro.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    UPDATE ct.Capacitador
    SET numero_registro = @numero_registro,
        nombre = @nombre,
        apellido = @apellido,
        telefono = @telefono,
        mail = @mail
    WHERE id_capacitador = @id_capacitador;
END
GO

CREATE OR ALTER PROCEDURE csp.BajaCapacitador
    @id_capacitador INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Capacitador WHERE id_capacitador = @id_capacitador)
    BEGIN
        RAISERROR('El capacitador no existe.',16,1);
        RETURN;
    END;

    DELETE FROM ct.Capacitador
    WHERE id_capacitador = @id_capacitador;
END
GO


/*
=========================================================
SP: csp.AltaCertificado
Descripción:
Permite registrar un certificado asociado a un capacitador.

Validaciones:
- El capacitador debe existir
- La fecha no puede ser futura
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaCertificado
    @id_capacitador INT,
    @fecha_capacitacion DATE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Capacitador WHERE id_capacitador = @id_capacitador)
        SET @errores += 'El capacitador no existe.' + CHAR(13);

    IF (@fecha_capacitacion > GETDATE())
        SET @errores += 'La fecha no puede ser futura.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Certificado(id_capacitador, fecha_capacitacion)
    VALUES(@id_capacitador, @fecha_capacitacion);
END
GO


CREATE OR ALTER PROCEDURE csp.BajaCertificado
    @id_certificado INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Certificado WHERE id_certificado = @id_certificado)
    BEGIN
        RAISERROR('El certificado no existe.',16,1);
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM ct.Vendedor WHERE id_certificado = @id_certificado)
    BEGIN
        RAISERROR('No se puede eliminar el certificado porque está asociado a un vendedor.',16,1);
        RETURN;
    END;

    DELETE FROM ct.Certificado
    WHERE id_certificado = @id_certificado;
END
GO


/*
=========================================================
SP: csp.AltaVendedor
Descripción:
Permite registrar un vendedor en una sucursal.

Validaciones:
- La sucursal debe existir
- El certificado debe existir
- No permitir duplicado (PK compuesta)
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaVendedor
    @id_vendedor INT,
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @id_sucursal INT,
    @id_certificado INT
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Sucursal WHERE id_sucursal = @id_sucursal)
        SET @errores += 'La sucursal no existe.' + CHAR(13);

    IF NOT EXISTS (SELECT 1 FROM ct.Certificado WHERE id_certificado = @id_certificado)
        SET @errores += 'El certificado no existe.' + CHAR(13);

    IF EXISTS (SELECT 1 FROM ct.Vendedor 
               WHERE id_vendedor = @id_vendedor 
               AND id_sucursal = @id_sucursal)
        SET @errores += 'El vendedor ya existe en esa sucursal.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Vendedor
    VALUES(@id_vendedor, @nombre, @apellido, @id_sucursal, @id_certificado);
END
GO

/*
=========================================================
SP: csp.BajaVendedor
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaVendedor
    @id_vendedor INT,
    @id_sucursal INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Vendedor 
                   WHERE id_vendedor = @id_vendedor 
                   AND id_sucursal = @id_sucursal)
    BEGIN
        RAISERROR('El vendedor no existe.',16,1);
        RETURN;
    END;

    DELETE FROM ct.Vendedor
    WHERE id_vendedor = @id_vendedor
      AND id_sucursal = @id_sucursal;
END
GO


/*
=========================================================
SP: csp.AltaVenta
Descripción:
Permite registrar una venta.

Validaciones:
- Fecha no puede ser futura
- Modalidad válida
- Canal válido
- Vendedor debe existir (PK compuesta)
- Cliente debe existir si se informa
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaVenta
    @fecha DATETIME,
    @modalidad VARCHAR(50),
    @canal VARCHAR(50),
    @id_vendedor INT,
    @id_sucursal INT,
    @id_cliente INT = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@fecha > GETDATE())
        SET @errores += 'La fecha no puede ser futura.' + CHAR(13);

    IF (@modalidad NOT IN ('presencial','domicilio'))
        SET @errores += 'Modalidad inválida.' + CHAR(13);

    IF (@canal NOT IN ('propio','plataforma'))
        SET @errores += 'Canal inválido.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1 FROM ct.Vendedor
        WHERE id_vendedor = @id_vendedor
        AND id_sucursal = @id_sucursal)
        SET @errores += 'El vendedor no existe en esa sucursal.' + CHAR(13);

    IF (@id_cliente IS NOT NULL AND
        NOT EXISTS (SELECT 1 FROM ct.Cliente WHERE id_cliente = @id_cliente))
        SET @errores += 'El cliente no existe.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.Venta
    VALUES(@fecha, @modalidad, @canal, @id_vendedor, @id_sucursal, @id_cliente);
END
GO

/*
=========================================================
SP: csp.BajaVenta
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaVenta
    @id_venta INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.Venta WHERE id_venta = @id_venta)
    BEGIN
        RAISERROR('La venta no existe.',16,1);
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM ct.DetalleVenta WHERE id_venta = @id_venta)
    BEGIN
        RAISERROR('No se puede eliminar la venta porque tiene detalles asociados.',16,1);
        RETURN;
    END;

    DELETE FROM ct.Venta WHERE id_venta = @id_venta;
END
GO


/*
=========================================================
SP: csp.AltaDetalleVenta
Descripción:
Permite agregar un detalle a una venta.

Validaciones:
- Venta debe existir
- Lote debe existir
- Cantidad > 0
- Precio > 0
=========================================================
*/
/*
CREATE OR ALTER PROCEDURE csp.AltaDetalleVenta
    @id_venta INT,
    @id_lote INT,
    @id_producto INT,
    @cantidad INT,
    @precio_unitario DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @errores NVARCHAR(MAX) = '';

    IF NOT EXISTS (SELECT 1 FROM ct.Venta WHERE id_venta = @id_venta)
        SET @errores += 'La venta no existe.' + CHAR(13);

    IF NOT EXISTS (
        SELECT 1 FROM ct.Lote
        WHERE id_lote = @id_lote
        AND id_producto = @id_producto)
        SET @errores += 'El lote no existe.' + CHAR(13);

    IF (@cantidad <= 0)
        SET @errores += 'La cantidad debe ser mayor a 0.' + CHAR(13);

    IF (@precio_unitario <= 0)
        SET @errores += 'El precio debe ser mayor a 0.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.DetalleVenta
    VALUES(@id_venta, @id_lote, @id_producto, @cantidad, @precio_unitario);
END
GO
*/

CREATE OR ALTER PROCEDURE csp.AltaDetalleVenta
    @id_venta INT,
    @id_lote INT,
    @id_producto INT,
    @cantidad INT,
    @precio_unitario DECIMAL(10,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores NVARCHAR(MAX) = '';
    DECLARE @fechaVenc DATE;
    DECLARE @stockDisponible INT;

    -- Validar venta
    IF NOT EXISTS (SELECT 1 FROM ct.Venta WHERE id_venta = @id_venta)
        SET @errores += 'La venta no existe.' + CHAR(13);

    -- Validar lote
    IF NOT EXISTS (
        SELECT 1 FROM ct.Lote
        WHERE id_lote = @id_lote
        AND id_producto = @id_producto)
        SET @errores += 'El lote no existe.' + CHAR(13);

    -- Validar cantidad
    IF (@cantidad <= 0)
        SET @errores += 'La cantidad debe ser mayor a 0.' + CHAR(13);

    -- Obtener fecha vencimiento y stock
    SELECT 
        @fechaVenc = fecha_vencimiento,
        @stockDisponible = cantidad_inicial
    FROM ct.Lote
    WHERE id_lote = @id_lote
      AND id_producto = @id_producto;

    -- Validar vencimiento
    IF (@fechaVenc < GETDATE())
        SET @errores += 'No se puede vender un producto vencido.' + CHAR(13);

    -- Validar stock
    IF (@cantidad > @stockDisponible)
        SET @errores += 'Stock insuficiente en el lote.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    -- Insertar detalle
    INSERT INTO ct.DetalleVenta
    VALUES(@id_venta, @id_lote, @id_producto, @cantidad, @precio_unitario);

    -- Descontar stock
    UPDATE ct.Lote
    SET cantidad_inicial = cantidad_inicial - @cantidad
    WHERE id_lote = @id_lote
      AND id_producto = @id_producto;

END
GO


/*
=========================================================
SP: csp.BajaDetalleVenta
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.BajaDetalleVenta
    @id_venta INT
AS
BEGIN
    IF NOT EXISTS (SELECT 1 FROM ct.DetalleVenta WHERE id_venta = @id_venta)
    BEGIN
        RAISERROR('El detalle no existe.',16,1);
        RETURN;
    END;

    DELETE FROM ct.DetalleVenta
    WHERE id_venta = @id_venta;
END
GO


USE Com2343;
GO

/*
=========================================================
SP: csp.AltaPrecioMayorista
Descripción:
Permite registrar un precio mayorista histórico
para una especie determinada.

Validaciones:
- Fecha no puede ser futura
- Tipo producto debe ser 'fruta' o 'hortaliza'
- Especie obligatoria
- Precio mayorista > 0
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AltaPrecioMayorista
    @fecha DATE,
    @tipo_producto VARCHAR(20),
    @especie VARCHAR(150),
    @precio_mayorista DECIMAL(18,2)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @errores NVARCHAR(MAX) = '';

    IF (@fecha > GETDATE())
        SET @errores += 'La fecha no puede ser futura.' + CHAR(13);

    IF (@tipo_producto NOT IN ('fruta','hortaliza'))
        SET @errores += 'Tipo de producto inválido.' + CHAR(13);

    IF (@especie IS NULL OR LTRIM(RTRIM(@especie)) = '')
        SET @errores += 'La especie es obligatoria.' + CHAR(13);

    IF (@precio_mayorista <= 0)
        SET @errores += 'El precio debe ser mayor a 0.' + CHAR(13);

    IF (@errores <> '')
    BEGIN
        RAISERROR(@errores,16,1);
        RETURN;
    END;

    INSERT INTO ct.PrecioMayorista
    (fecha, tipo_producto, especie, precio_mayorista)
    VALUES
    (@fecha, @tipo_producto, @especie, @precio_mayorista);
END
GO

CREATE OR ALTER PROCEDURE csp.AltaMerma
    @id_producto INT,
    @id_sucursal INT,
    @fecha DATE,
    @cantidad INT
AS
BEGIN
    SET NOCOUNT ON;

    IF @cantidad <= 0
    BEGIN
        RAISERROR('La cantidad debe ser mayor a 0.',16,1);
        RETURN;
    END;

    IF EXISTS (
        SELECT 1 
        FROM ct.Merma
        WHERE id_producto = @id_producto
          AND id_sucursal = @id_sucursal
          AND fecha = @fecha
    )
    BEGIN
        UPDATE ct.Merma
        SET cantidad = cantidad + @cantidad
        WHERE id_producto = @id_producto
          AND id_sucursal = @id_sucursal
          AND fecha = @fecha;
    END
    ELSE
    BEGIN
        INSERT INTO ct.Merma(id_producto, id_sucursal, fecha, cantidad)
        VALUES(@id_producto, @id_sucursal, @fecha, @cantidad);
    END
END
GO