/*
============================================================
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas
Grupo:
    - Leonel Cespedes
    - Luciana Franchetti

Descripción:
Script de carga de datos (Seed Data) y casos de prueba.
Cumple con los criterios de aceptación del TP:

- 20 sucursales
- 5 proveedores activos
- 50 productos variados (unidad y granel)
- Lotes en 3 meses distintos
- Venta que consume 2 lotes (FIFO / FEFO)
- Validación de producto vencido
============================================================
*/
/*
============================================================
PASO 1: Generación automática de 20 sucursales
============================================================
*/

DECLARE @i INT = 1;
DECLARE @nombre VARCHAR(100);
DECLARE @direccion VARCHAR(200);

WHILE @i <= 20
BEGIN
    SET @nombre = 'Sucursal ' + CAST(@i AS VARCHAR(10));
    SET @direccion = 'Direccion ' + CAST(@i AS VARCHAR(10));

    -- Evita insertar duplicados
    IF NOT EXISTS (
        SELECT 1 
        FROM ct.Sucursal 
        WHERE nombre = @nombre
    )
    BEGIN
        EXEC csp.AltaSucursal
            @nombre = @nombre,
            @direccion = @direccion;
    END;

    SET @i = @i + 1;
END;
GO

-- Verificación
SELECT COUNT(*) AS TotalSucursales FROM ct.Sucursal;



/*
============================================================
PASO 2: Creación de 5 proveedores activos
============================================================
*/

DECLARE @i INT = 1;
DECLARE @nombre VARCHAR(100);
DECLARE @telefono VARCHAR(20);
DECLARE @cuit VARCHAR(20);

WHILE @i <= 5
BEGIN
    SET @nombre = 'Proveedor' + CAST(@i AS VARCHAR(10));
    SET @telefono = '11111' + CAST(@i AS VARCHAR(10));
    SET @cuit = '20-1234567' + CAST(@i AS VARCHAR(1)) + '-1';

    IF NOT EXISTS (
        SELECT 1 
        FROM ct.Proveedor 
        WHERE cuit = @cuit
    )
    BEGIN
        EXEC csp.AltaProveedor
            @nombre = @nombre,
            @apellido = 'Activo',
            @telefono = @telefono,
            @cuit = @cuit;
    END

    SET @i = @i + 1;
END;
GO

SELECT COUNT(*) AS TotalProveedores FROM ct.Proveedor;


/*
============================================================
PASO 3: Generación de 50 productos variados
============================================================
*/

-- Crear categoría si no existe
IF NOT EXISTS (SELECT 1 FROM ct.Categoria WHERE nombre = 'General')
BEGIN
    EXEC csp.AltaCategoria
        @nombre = 'General',
        @margen_ganancia = 30;
END
GO

DECLARE @i INT = 1;
DECLARE @idCategoria INT;
DECLARE @nombre VARCHAR(50);
DECLARE @forma VARCHAR(20);

SELECT @idCategoria = id_categoria
FROM ct.Categoria
WHERE nombre = 'General';

WHILE @i <= 50
BEGIN
    SET @nombre = 'Producto ' + CAST(@i AS VARCHAR(10));

    IF (@i % 2 = 0)
        SET @forma = 'granel';
    ELSE
        SET @forma = 'unidad';

    IF NOT EXISTS (
        SELECT 1 
        FROM ct.Producto 
        WHERE nombre = @nombre
    )
    BEGIN
        EXEC csp.AltaProducto
            @nombre = @nombre,
            @descripcion = 'Producto de prueba',
            @forma_comercializacion = @forma,
            @tipo_producto_agricola = 'hoja verde',
            @vida_util = 30,
            @id_categoria = @idCategoria;
    END;

    SET @i = @i + 1;
END;
GO

SELECT COUNT(*) AS TotalProductos FROM ct.Producto;


/*
============================================================
PASO 4: Creación de lotes en 3 meses distintos
============================================================
*/

-- LOTES
DECLARE @idProducto INT = 1;
DECLARE @fechaIngreso DATE;
DECLARE @fechaVenc DATE;

-- Enero
SET @fechaIngreso = DATEADD(MONTH, -3, GETDATE());
SET @fechaVenc = DATEADD(DAY, 20, @fechaIngreso);

EXEC csp.AltaLote
    @id_lote = 1,
    @id_producto = @idProducto,
    @cantidad_inicial = 100,
    @costo = 500,
    @fecha_ingreso = @fechaIngreso,
    @fecha_vencimiento = @fechaVenc;

-- Febrero
SET @fechaIngreso = DATEADD(MONTH, -2, GETDATE());
SET @fechaVenc = DATEADD(DAY, 20, @fechaIngreso);

EXEC csp.AltaLote
    @id_lote = 2,
    @id_producto = @idProducto,
    @cantidad_inicial = 150,
    @costo = 520,
    @fecha_ingreso = @fechaIngreso,
    @fecha_vencimiento = @fechaVenc;

-- Marzo
SET @fechaIngreso = DATEADD(MONTH, -1, GETDATE());
SET @fechaVenc = DATEADD(DAY, 20, @fechaIngreso);

EXEC csp.AltaLote
    @id_lote = 3,
    @id_producto = @idProducto,
    @cantidad_inicial = 200,
    @costo = 550,
    @fecha_ingreso = @fechaIngreso,
    @fecha_vencimiento = @fechaVenc;

-- =====================================
-- Crear Capacitador
-- =====================================

DECLARE @numeroRegistro VARCHAR(50);
SET @numeroRegistro = 'REG1';

IF NOT EXISTS (
    SELECT 1 FROM ct.Capacitador 
    WHERE numero_registro = @numeroRegistro
)
BEGIN
    EXEC csp.AltaCapacitador
        @numero_registro = @numeroRegistro,
        @nombre = 'Carlos',
        @apellido = 'Gomez',
        @telefono = '123456',
        @mail = 'carlos@mail.com';
END;


-- =====================================
-- Obtener id del capacitador
-- =====================================

DECLARE @idCapacitador INT;

SELECT @idCapacitador = id_capacitador
FROM ct.Capacitador
WHERE numero_registro = @numeroRegistro;


-- =====================================
-- Crear Certificado
-- =====================================

DECLARE @fechaCert DATE;
SET @fechaCert = DATEADD(MONTH, -4, GETDATE());

IF NOT EXISTS (
    SELECT 1 
    FROM ct.Certificado 
    WHERE id_capacitador = @idCapacitador
)
BEGIN
    EXEC csp.AltaCertificado
        @id_capacitador = @idCapacitador,
        @fecha_capacitacion = @fechaCert;
END;


-- =====================================
-- Obtener id del certificado
-- =====================================

DECLARE @idCertificado INT;

SELECT TOP 1 @idCertificado = id_certificado
FROM ct.Certificado
WHERE id_capacitador = @idCapacitador;


-- =====================================
-- Crear Vendedor en Sucursal 1
-- =====================================

IF NOT EXISTS (
    SELECT 1 
    FROM ct.Vendedor
    WHERE id_vendedor = 1
    AND id_sucursal = 1
)
BEGIN
    EXEC csp.AltaVendedor
        @id_vendedor = 1,
        @nombre = 'Ana',
        @apellido = 'Lopez',
        @id_sucursal = 1,
        @id_certificado = @idCertificado;
END;


/*
============================================================
PASO 5: Venta que consume stock de dos lotes
============================================================
*/

DECLARE @fechaVenta DATETIME;
SET @fechaVenta = DATEADD(MONTH, -1, GETDATE());

EXEC csp.AltaVenta
    @fecha = @fechaVenta,
    @modalidad = 'presencial',
    @canal = 'propio',
    @id_vendedor = 1,
    @id_sucursal = 1,
    @id_cliente = NULL;

-- Ajuste de PK para permitir múltiples lotes por venta
ALTER TABLE ct.DetalleVenta
DROP CONSTRAINT PK_DetalleVenta;
GO

ALTER TABLE ct.DetalleVenta
ADD CONSTRAINT PK_DetalleVenta
PRIMARY KEY (id_venta, id_lote, id_producto);
GO

-- Consumo de lote 1
EXEC csp.AltaDetalleVenta
    @id_venta = 1,
    @id_lote = 1,
    @id_producto = 1,
    @cantidad = 100,
    @precio_unitario = 800;

-- Consumo de lote 2
EXEC csp.AltaDetalleVenta
    @id_venta = 1,
    @id_lote = 2,
    @id_producto = 1,
    @cantidad = 20,
    @precio_unitario = 800;
