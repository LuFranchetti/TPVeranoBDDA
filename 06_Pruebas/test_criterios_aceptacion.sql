/*
============================================================
ENTREGA 7 – CRITERIOS DE ACEPTACIÓN (JUEGO DE DATOS)
============================================================

Cumple con:
- 20 Sucursales
- 5 Proveedores activos
- 50 Productos (unidad + granel)
- Historial de 3 meses
- Producto con 3 lotes distintos
- Venta que consume 2 lotes (FEFO)
- Intento de venta de producto vencido
============================================================
*/

USE Com2343;
GO
SET NOCOUNT ON
/* =========================================================
1) 20 SUCURSALES
========================================================= */

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
        FROM productos.Sucursal 
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
PRINT '==============================';
PRINT 'VERIFICACION DE SUCURSALES';
PRINT '==============================';

SELECT COUNT(*) AS TotalSucursales FROM productos.Sucursal;

/* =========================================================
2) 5 PROVEEDORES ACTIVOS
========================================================= */

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
        FROM proveedores.Proveedor 
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

PRINT '==============================';
PRINT 'VERIFICACION DE PROVEEDORES';
PRINT '==============================';
SELECT COUNT(*) AS TotalProveedores FROM proveedores.Proveedor;

/* =========================================================
3) 50 PRODUCTOS (MITAD GRANEL / MITAD UNIDAD)
========================================================= */

-- Crear categoría si no existe
IF NOT EXISTS (SELECT 1 FROM productos.Categoria WHERE nombre = 'General')
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
FROM productos.Categoria
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
        FROM productos.Producto 
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

PRINT '==============================';
PRINT 'VERIFICACION DE PRODUCTOS';
PRINT '==============================';

SELECT COUNT(*) AS TotalProductos FROM productos.Producto;


/*
============================================================
DATOS COMPLETOS PARA HISTORIAL DE VENTAS DE 3 MESES
============================================================
Crea:
- Categoria
- Proveedor
- Temporada
- Sucursal
- Stock
- Producto
- 3 lotes
- Capacitador
- Certificado
- Vendedor
- Historial de ventas (3 meses)
============================================================
*/

USE Com2343;
GO

/* CATEGORIA */

IF NOT EXISTS (SELECT 1 FROM productos.Categoria WHERE nombre='General')
BEGIN
    EXEC csp.AltaCategoria 'General',30;
END

DECLARE @idCategoria INT =
(SELECT TOP 1 id_categoria FROM productos.Categoria WHERE nombre='General');


/* PROVEEDOR */

IF NOT EXISTS (SELECT 1 FROM proveedores.Proveedor WHERE apellido='Perez')
BEGIN
    EXEC csp.AltaProveedor
        'Juan',
        'Perez',
        '111111',
        '20-12345678-9';
END

DECLARE @idProveedor INT =
(SELECT TOP 1 id_proveedor FROM proveedores.Proveedor);


/* TEMPORADA */

IF NOT EXISTS (SELECT 1 FROM productos.Temporada WHERE nombre='Temporada General')
BEGIN
    EXEC csp.AltaTemporada
        'Temporada General',
        'Productos disponibles todo el año',
        '2025-01-01',
        '2026-12-31';
END

DECLARE @idTemporada INT =
(SELECT TOP 1 id_temporada FROM productos.Temporada);


/* SUCURSAL */

IF NOT EXISTS (SELECT 1 FROM productos.Sucursal WHERE nombre='Sucursal Central')
BEGIN
    EXEC csp.AltaSucursal
        'Sucursal Central',
        'Av Siempre Viva 123';
END

DECLARE @idSucursal INT =
(SELECT TOP 1 id_sucursal FROM productos.Sucursal);


/* STOCK */

EXEC csp.AltaStock
    @id_sucursal = @idSucursal,
    @stock_minimo = 10,
    @fecha_ultima_actualizacion = '2026-03-01';

DECLARE @idStock INT =
(SELECT TOP 1 id_stock FROM productos.Stock);


/* PRODUCTO */

IF NOT EXISTS (SELECT 1 FROM productos.Producto WHERE nombre='Producto Test')
BEGIN
    EXEC csp.AltaProducto
        'Producto Test',
        'Producto para pruebas',
        'unidad',
        'hoja verde',
        30,
        @idCategoria,
        @idStock,
        @idTemporada,
        @idProveedor;
END

DECLARE @idProducto INT =
(SELECT TOP 1 id_producto FROM productos.Producto);


/* LOTES */

EXEC csp.AltaLote
    1,
    @idProducto,
    100,
    500,
    '2025-12-01',
    '2026-12-01';

EXEC csp.AltaLote
    2,
    @idProducto,
    100,
    520,
    '2026-01-01',
    '2026-12-01';

EXEC csp.AltaLote
    3,
    @idProducto,
    100,
    550,
    '2026-02-01',
    '2026-12-01';

/* CAPACITADOR */

IF NOT EXISTS (SELECT 1 FROM ventas.Capacitador WHERE numero_registro='REG1')
BEGIN
    EXEC csp.AltaCapacitador
        'REG1',
        'Carlos',
        'Gomez',
        '123456',
        'mail@test.com';
END

DECLARE @idCapacitador INT =
(SELECT TOP 1 id_capacitador FROM ventas.Capacitador);


/* CERTIFICADO */

EXEC csp.AltaCertificado
    @idCapacitador,
    '2025-11-01';

DECLARE @idCertificado INT =
(SELECT TOP 1 id_certificado FROM ventas.Certificado);


/* VENDEDOR */

IF NOT EXISTS (
    SELECT 1 FROM ventas.Vendedor
    WHERE id_vendedor=1 AND id_sucursal=@idSucursal
)
BEGIN
    EXEC csp.AltaVendedor
        1,
        'Ana',
        'Lopez',
        @idSucursal,
        @idCertificado;
END

/* HISTORIAL DE VENTAS – 3 MESES */

DECLARE @mes INT = 3;
DECLARE @contador INT;
DECLARE @fechaVenta DATETIME;
DECLARE @idVenta INT;

WHILE @mes >= 1
BEGIN
    SET @contador = 1;

    WHILE @contador <= 5
    BEGIN

        SET @fechaVenta = DATEADD(MONTH, -@mes, CAST('2026-03-01' AS DATE));

        EXEC csp.AltaVenta
            @fecha = @fechaVenta,
            @modalidad = 'presencial',
            @canal = 'propio',
            @id_vendedor = 1,
            @id_sucursal = @idSucursal,
            @id_cliente = NULL;

        SELECT @idVenta = MAX(id_venta)
        FROM ventas.Venta;

        EXEC csp.AltaDetalleVenta
            @id_venta = @idVenta,
            @id_lote = 3,
            @id_producto = @idProducto,
            @cantidad = 5,
            @precio_unitario = 800;

        SET @contador = @contador + 1;
    END

    SET @mes = @mes - 1;
END


/* VERIFICACION */
PRINT '==============================';
PRINT 'HISTORIAL DE VENTAS 3 MESES';
PRINT '==============================';

SELECT
    YEAR(fecha) AS Anio,
    MONTH(fecha) AS Mes,
    COUNT(*) AS CantidadVentas
FROM ventas.Venta
GROUP BY YEAR(fecha), MONTH(fecha)
ORDER BY Anio, Mes;




/* VERIFICACION: PRODUCTO CON 3 LOTES */
PRINT '==============================';
PRINT 'VERIFICACION DE PRODUCTO EN 3 LOTES';
PRINT '==============================';

SELECT
    p.nombre AS Producto,
    l.id_lote,
    l.cantidad_inicial,
    l.fecha_ingreso,
    l.fecha_vencimiento
FROM productos.Lote l
JOIN productos.Producto p
ON p.id_producto = l.id_producto
WHERE p.id_producto = @idProducto;



/* VENTA QUE CONSUME DOS LOTES (FIFO / FEFO) */

EXEC csp.AltaVenta
    '2026-02-01',
    'presencial',
    'propio',
    1,
    @idSucursal,
    NULL;

DECLARE @idVentaTest INT =
(SELECT MAX(id_venta) FROM ventas.Venta);


-- Consume todo el lote 1
EXEC csp.AltaDetalleVenta
    @idVentaTest,
    1,
    @idProducto,
    100,
    800;

-- Consume parte del lote 2
EXEC csp.AltaDetalleVenta
    @idVentaTest,
    2,
    @idProducto,
    20,
    800;


/* VERIFICACION: VENTA QUE USA DOS LOTES */
PRINT '==============================';
PRINT 'VERIFICACION DE VENTA QUE USA DOS LOTES';
PRINT '==============================';

SELECT
    v.id_venta,
    p.nombre AS producto,
    dv.id_lote,
    dv.cantidad
FROM ventas.DetalleVenta dv
JOIN ventas.Venta v
ON v.id_venta = dv.id_venta
JOIN productos.Producto p
ON p.id_producto = dv.id_producto
WHERE v.id_venta = @idVentaTest;





/* =========================================================
INTENTO DE VENTA DE PRODUCTO VENCIDO (CASO DE PRUEBA)
El sistema debe bloquear la venta.
========================================================= */

-- Crear lote vencido

EXEC csp.AltaLote
    99,
    @idProducto,
    50,
    400,
    '2025-01-01',
    '2025-02-01';   -- ya vencido


-- Crear una venta

EXEC csp.AltaVenta
    '2026-03-01',
    'presencial',
    'propio',
    1,
    @idSucursal,
    NULL;

DECLARE @ventaVencida INT =
(SELECT MAX(id_venta) FROM ventas.Venta);


-- Intentar vender producto vencido
-- ESTE EXEC DEBE FALLAR

EXEC csp.AltaDetalleVenta
    @ventaVencida,
    99,
    @idProducto,
    5,
    800;


























