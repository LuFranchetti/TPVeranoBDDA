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

/* =========================================================
1️⃣ 20 SUCURSALES
========================================================= */

DECLARE @i INT = 1;

WHILE @i <= 20
BEGIN
    IF NOT EXISTS (
        SELECT 1 
        FROM productos.Sucursal 
        WHERE nombre = 'Sucursal ' + CAST(@i AS VARCHAR)
    )
    BEGIN
        EXEC csp.AltaSucursal
            @nombre = 'Sucursal ' + CAST(@i AS VARCHAR),
            @direccion = 'Direccion ' + CAST(@i AS VARCHAR);
    END

    SET @i += 1;
END
GO

/* =========================================================
2️⃣ 5 PROVEEDORES ACTIVOS
========================================================= */

SET @i = 1;

WHILE @i <= 5
BEGIN
    DECLARE @cuit VARCHAR(20) = 
        '20-1234567' + CAST(@i AS VARCHAR) + '-1';

    IF NOT EXISTS (
        SELECT 1 
        FROM proveedores.Proveedor 
        WHERE CONVERT(VARCHAR(100),DecryptByKey(cuit)) = @cuit
    )
    BEGIN
        EXEC csp.AltaProveedor
            @nombre = 'Proveedor' + CAST(@i AS VARCHAR),
            @apellido = 'Activo',
            @telefono = '11111' + CAST(@i AS VARCHAR),
            @cuit = @cuit;
    END

    SET @i += 1;
END
GO

/* =========================================================
3️⃣ 50 PRODUCTOS (MITAD GRANEL / MITAD UNIDAD)
========================================================= */

DECLARE @idCategoria INT =
(SELECT TOP 1 id_categoria FROM productos.Categoria);

SET @i = 1;

WHILE @i <= 50
BEGIN
    DECLARE @nombreProducto VARCHAR(50) =
        'Producto_' + CAST(@i AS VARCHAR);

    IF NOT EXISTS (
        SELECT 1 FROM productos.Producto 
        WHERE nombre = @nombreProducto
    )
    BEGIN
        EXEC csp.AltaProducto
            @nombre = @nombreProducto,
            @descripcion = 'Producto de prueba',
            @forma_comercializacion =
                CASE WHEN @i % 2 = 0 THEN 'granel'
                     ELSE 'unidad' END,
            @tipo_producto_agricola = 'hoja verde',
            @vida_util = 30,
            @id_categoria = @idCategoria,
            @id_stock = NULL,
            @id_temporada = NULL,
            @id_proveedor = 1;
    END

    SET @i += 1;
END
GO

/* =========================================================
4️⃣ HISTORIAL DE 3 MESES – LOTES
========================================================= */

DECLARE @idProducto INT =
(SELECT TOP 1 id_producto FROM productos.Producto);

-- Lote hace 3 meses
EXEC csp.AltaLote
    1,@idProducto,100,500,
    DATEADD(MONTH,-3,GETDATE()),
    DATEADD(MONTH,-3,GETDATE()) + 30;

-- Lote hace 2 meses
EXEC csp.AltaLote
    2,@idProducto,150,520,
    DATEADD(MONTH,-2,GETDATE()),
    DATEADD(MONTH,-2,GETDATE()) + 30;

-- Lote hace 1 mes
EXEC csp.AltaLote
    3,@idProducto,200,550,
    DATEADD(MONTH,-1,GETDATE()),
    DATEADD(MONTH,-1,GETDATE()) + 30;
GO

/* =========================================================
5️⃣ CASO: PRODUCTO CON 3 LOTES DISTINTOS
========================================================= */

-- Ya generado arriba (lotes 1,2,3 con fechas distintas)

/* =========================================================
6️⃣ CASO: VENTA QUE CONSUME DOS LOTES (FEFO)
========================================================= */

DECLARE @idSucursal INT = 1;

EXEC csp.AltaVenta
    GETDATE(),
    'presencial',
    'propio',
    1,
    @idSucursal,
    NULL;

DECLARE @idVenta INT =
(SELECT MAX(id_venta) FROM ventas.Venta);

-- Consumo lote más antiguo primero
EXEC csp.AltaDetalleVenta
    @idVenta,1,@idProducto,100,800;

-- Luego siguiente lote
EXEC csp.AltaDetalleVenta
    @idVenta,2,@idProducto,20,800;
GO

/* =========================================================
7️⃣ CASO: INTENTO DE VENTA DE PRODUCTO VENCIDO
========================================================= */

-- Lote vencido
EXEC csp.AltaLote
    99,@idProducto,50,400,
    DATEADD(MONTH,-4,GETDATE()),
    DATEADD(MONTH,-3,GETDATE()); -- vencido

-- Intento de venta (debe ser bloqueado si el SP valida vencimiento)
EXEC csp.AltaDetalleVenta
    @idVenta,99,@idProducto,10,800;
GO