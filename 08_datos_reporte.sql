/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
    Componentes del grupo:
        - Leonel Cespedes
        - Luciana Franchetti

    Descripción: Inserción de datos
*/

USE Com2343;
GO

/* ====================================================
   1️⃣ CATEGORIAS
===================================================== */

EXEC csp.AltaCategoria 'Frutas', 30;
EXEC csp.AltaCategoria 'Hortalizas', 25;
EXEC csp.AltaCategoria 'Tuberculos', 20;
EXEC csp.AltaCategoria 'Organicos', 40;

DECLARE @catFrutas INT = (SELECT id_categoria FROM productos.Categoria WHERE nombre='Frutas');
DECLARE @catHortalizas INT = (SELECT id_categoria FROM productos.Categoria WHERE nombre='Hortalizas');
DECLARE @catTuberculos INT = (SELECT id_categoria FROM productos.Categoria WHERE nombre='Tuberculos');
DECLARE @catOrganicos INT = (SELECT id_categoria FROM productos.Categoria WHERE nombre='Organicos');


/* =====================================================
   2️⃣ SUCURSALES + STOCK
===================================================== */

EXEC csp.AltaSucursal 'Ramos Mejia', 'Av Siempre Viva 123';
DECLARE @idSucursalRamosMejia INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Ramos Mejia');
EXEC csp.AltaStock @idSucursalRamosMejia, 10, '2026-03-01';

EXEC csp.AltaSucursal 'San Justo', 'Av Siempre Viva 123';
DECLARE @idSucursalSanJusto INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='San Justo');
EXEC csp.AltaStock @idSucursalSanJusto, 10, '2026-03-01';

EXEC csp.AltaSucursal 'Haedo', 'Av Siempre Viva 123';
DECLARE @idSucursalHaedo INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Haedo');
EXEC csp.AltaStock @idSucursalHaedo, 10, '2026-03-01';

EXEC csp.AltaSucursal 'Moron', 'Av Siempre Viva 123';
DECLARE @idSucursalMoron INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Moron');
EXEC csp.AltaStock @idSucursalMoron, 10, '2026-03-01';


/* =====================================================
   3️⃣ PROVEEDOR
===================================================== */

EXEC csp.AltaProveedor 'Juan','Perez','111111','20-12345678-9';

DECLARE @idProveedor INT =
(SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-12345678-9');


/* =====================================================
   4️⃣ TEMPORADA
===================================================== */

EXEC csp.AltaTemporada 'Verano 2026','Temporada alta','2026-01-01','2026-12-31';

DECLARE @idTemporada INT =
(SELECT id_temporada FROM productos.Temporada WHERE nombre='Verano 2026');


/* =====================================================
   5️⃣ PRODUCTOS
===================================================== */

EXEC csp.AltaProducto 'Manzana','Roja','unidad','hoja verde',30,@catFrutas,NULL,@idTemporada,@idProveedor;
EXEC csp.AltaProducto 'Banana','Ecuador','unidad','hoja verde',20,@catFrutas,NULL,@idTemporada,@idProveedor;
EXEC csp.AltaProducto 'Lechuga','Criolla','unidad','hoja verde',10,@catHortalizas,NULL,@idTemporada,@idProveedor;
EXEC csp.AltaProducto 'Papa','Blanca','unidad','tuberculo',60,@catTuberculos,NULL,@idTemporada,@idProveedor;
EXEC csp.AltaProducto 'Espinaca','Organica','unidad','hoja verde',7,@catOrganicos,NULL,@idTemporada,@idProveedor;

DECLARE @idManzana INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Manzana');
DECLARE @idBanana INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Banana');
DECLARE @idLechuga INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Lechuga');
DECLARE @idPapa INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Papa');
DECLARE @idEspinaca INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Espinaca');


/* =====================================================
   6️⃣ LOTES
===================================================== */

EXEC csp.AltaLote 1,@idManzana,500,50,'2026-03-01','2026-04-01';
EXEC csp.AltaLote 2,@idBanana,500,40,'2026-03-01','2026-04-01';
EXEC csp.AltaLote 3,@idLechuga,500,20,'2026-03-01','2026-03-20';
EXEC csp.AltaLote 4,@idPapa,500,35,'2026-03-01','2026-05-01';
EXEC csp.AltaLote 5,@idEspinaca,300,60,'2026-03-01','2026-03-15';


/* =====================================================
   7️⃣ CLIENTE
===================================================== */

EXEC csp.AltaCliente 'Carlos','Gomez','123456','Calle Falsa 123','registrado';

DECLARE @idCliente INT =
(SELECT id_cliente FROM ventas.Cliente WHERE nombre='Carlos');


/* =====================================================
   8️⃣ CAPACITADOR + CERTIFICADO
===================================================== */

EXEC csp.AltaCapacitador 'REG001','Mario','Lopez','1111','mail@test.com';

DECLARE @idCap INT =
(SELECT id_capacitador FROM ventas.Capacitador WHERE numero_registro='REG001');

EXEC csp.AltaCertificado @idCap, '2026-02-01';

DECLARE @idCert INT =
(SELECT TOP 1 id_certificado FROM ventas.Certificado WHERE id_capacitador=@idCap);


/* =====================================================
   9️⃣ VENDEDOR
===================================================== */

EXEC csp.AltaVendedor 1,'Pedro','Martinez',@idSucursalRamosMejia,@idCert;


/* =====================================================
   🔟 VENTAS
===================================================== */

EXEC csp.AltaVenta '2026-03-01','presencial','propio',1,@idSucursalRamosMejia,@idCliente;
EXEC csp.AltaVenta '2026-03-02','domicilio','plataforma',1,@idSucursalRamosMejia,@idCliente;

DECLARE @venta1 INT = (SELECT MIN(id_venta) FROM ventas.Venta);
DECLARE @venta2 INT = (SELECT MAX(id_venta) FROM ventas.Venta);


/* =====================================================
   1️⃣1️⃣ DETALLE VENTAS
===================================================== */

EXEC csp.AltaDetalleVenta @venta1,1,@idManzana,50,100;
EXEC csp.AltaDetalleVenta @venta1,2,@idBanana,40,90;
EXEC csp.AltaDetalleVenta @venta2,1,@idManzana,30,110;
EXEC csp.AltaDetalleVenta @venta2,2,@idBanana,20,95;

EXEC csp.AltaDetalleVenta @venta1,3,@idLechuga,60,50;
EXEC csp.AltaDetalleVenta @venta2,3,@idLechuga,40,55;

EXEC csp.AltaDetalleVenta @venta1,4,@idPapa,80,50;
EXEC csp.AltaDetalleVenta @venta2,4,@idPapa,40,48;

EXEC csp.AltaDetalleVenta @venta1,5,@idEspinaca,30,150;
EXEC csp.AltaDetalleVenta @venta2,5,@idEspinaca,20,160;

GO


/* =====================================================
   🔹 MERMAS
===================================================== */

USE Com2343;
GO

-- 🔥 Re-declarar variables porque el GO las borra

DECLARE @idSucursalRamosMejia INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Ramos Mejia');

DECLARE @idSucursalSanJusto INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='San Justo');

DECLARE @manzana INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Manzana');
DECLARE @banana INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Banana');
DECLARE @lechuga INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Lechuga');
DECLARE @papa INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Papa');

-- Ramos Mejia
EXEC csp.AltaMerma @manzana, @idSucursalRamosMejia, '2026-03-01', 10;
EXEC csp.AltaMerma @banana,  @idSucursalRamosMejia, '2026-03-01', 5;
EXEC csp.AltaMerma @lechuga, @idSucursalRamosMejia, '2026-03-02', 7;
EXEC csp.AltaMerma @papa,    @idSucursalRamosMejia, '2026-03-03', 12;
EXEC csp.AltaMerma @manzana, @idSucursalRamosMejia, '2026-03-01', 3;

-- San Justo
EXEC csp.AltaMerma @manzana, @idSucursalSanJusto, '2026-03-01', 4;
EXEC csp.AltaMerma @banana,  @idSucursalSanJusto, '2026-03-02', 9;
EXEC csp.AltaMerma @papa,    @idSucursalSanJusto, '2026-03-02', 6;

GO


USE Com2343;
GO

/* =====================================================
   1️⃣ CATEGORÍAS
===================================================== */

IF NOT EXISTS (SELECT 1 FROM productos.Categoria WHERE nombre='Frutas')
    INSERT INTO productos.Categoria(nombre,margen_ganancia) VALUES('Frutas',30);

IF NOT EXISTS (SELECT 1 FROM productos.Categoria WHERE nombre='Hortalizas')
    INSERT INTO productos.Categoria(nombre,margen_ganancia) VALUES('Hortalizas',25);

DECLARE @catFrutas INT = (SELECT id_categoria FROM productos.Categoria WHERE nombre='Frutas');
DECLARE @catHortalizas INT = (SELECT id_categoria FROM productos.Categoria WHERE nombre='Hortalizas');


/* =====================================================
   2️⃣ PROVEEDORES
===================================================== */

INSERT INTO proveedores.Proveedor(nombre,apellido,telefono,cuit)
VALUES
('Juan','Perez','111','20-11111111-1'),
('Maria','Gomez','222','20-22222222-2'),
('Luis','Fernandez','333','20-33333333-3'),
('Ana','Lopez','444','20-44444444-4'),
('Carlos','Martinez','555','20-55555555-5');

DECLARE @p1 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-11111111-1');
DECLARE @p2 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-22222222-2');
DECLARE @p3 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-33333333-3');
DECLARE @p4 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-44444444-4');
DECLARE @p5 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-55555555-5');


/* =====================================================
   3️⃣ PRODUCTOS (IMPORTANTE: nombre = especie)
===================================================== */

INSERT INTO productos.Producto
(nombre,descripcion,forma_comercializacion,tipo_producto_agricola,
vida_util,id_categoria,id_stock,id_temporada,id_proveedor)
VALUES
('Manzana','Roja','unidad','hoja verde',30,@catFrutas,NULL,NULL,@p1),
('Banana','Ecuador','unidad','hoja verde',20,@catFrutas,NULL,NULL,@p2),
('Lechuga','Criolla','unidad','hoja verde',10,@catHortalizas,NULL,NULL,@p3),
('Papa','Blanca','unidad','tuberculo',60,@catHortalizas,NULL,NULL,@p4),
('Tomate','Redondo','unidad','hoja verde',15,@catHortalizas,NULL,NULL,@p5);


/* =====================================================
   4️⃣ PRECIOS MAYORISTAS (últimos 30 días)
===================================================== */

DECLARE @hoy DATE = CAST(GETDATE() AS DATE);

INSERT INTO importaciones.PrecioMayorista
(fecha,tipo_producto,especie,precio_mayorista)
VALUES
(DATEADD(DAY,-5,@hoy),'fruta','Manzana',50),
(DATEADD(DAY,-10,@hoy),'fruta','Manzana',55),

(DATEADD(DAY,-5,@hoy),'fruta','Banana',65),
(DATEADD(DAY,-8,@hoy),'fruta','Banana',60),

(DATEADD(DAY,-3,@hoy),'hortaliza','Lechuga',40),
(DATEADD(DAY,-6,@hoy),'hortaliza','Lechuga',45),

(DATEADD(DAY,-7,@hoy),'hortaliza','Papa',35),
(DATEADD(DAY,-12,@hoy),'hortaliza','Papa',30),

(DATEADD(DAY,-2,@hoy),'hortaliza','Tomate',42),
(DATEADD(DAY,-15,@hoy),'hortaliza','Tomate',39);

GO





USE Com2343;
GO

DECLARE @idSucursalHaedo INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Haedo');

DECLARE @idSucursalMoron INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Moron');

DECLARE @manzana INT =
(
    SELECT TOP 1 id_producto
    FROM productos.Producto
    WHERE nombre='Manzana'
    ORDER BY id_producto DESC
);

DECLARE @banana INT =
(
    SELECT TOP 1 id_producto
    FROM productos.Producto
    WHERE nombre='Banana'
    ORDER BY id_producto DESC
);

DECLARE @lechuga INT =
(
    SELECT TOP 1 id_producto
    FROM productos.Producto
    WHERE nombre='Lechuga'
    ORDER BY id_producto DESC
);

DECLARE @papa INT =
(
    SELECT TOP 1 id_producto
    FROM productos.Producto
    WHERE nombre='Papa'
    ORDER BY id_producto DESC
);

-- Haedo
EXEC csp.AltaMerma @manzana, @idSucursalHaedo, '2026-03-01', 8;
EXEC csp.AltaMerma @banana,  @idSucursalHaedo, '2026-03-02', 3;
EXEC csp.AltaMerma @papa,    @idSucursalHaedo, '2026-03-03', 9;

-- Moron
EXEC csp.AltaMerma @manzana, @idSucursalMoron, '2026-03-01', 11;
EXEC csp.AltaMerma @lechuga, @idSucursalMoron, '2026-03-02', 6;
EXEC csp.AltaMerma @papa,    @idSucursalMoron, '2026-03-03', 4;

GO








USE Com2343;
GO

-- Obtener stocks existentes
DECLARE @stockRamos INT =
(
    SELECT id_stock
    FROM productos.Stock st
    INNER JOIN productos.Sucursal s
        ON st.id_sucursal = s.id_sucursal
    WHERE s.nombre = 'Ramos Mejia'
);

DECLARE @stockSanJusto INT =
(
    SELECT id_stock
    FROM productos.Stock st
    INNER JOIN productos.Sucursal s
        ON st.id_sucursal = s.id_sucursal
    WHERE s.nombre = 'San Justo'
);

-- Obtener productos
DECLARE @manzana INT =
(
    SELECT TOP 1 id_producto
    FROM productos.Producto
    WHERE nombre='Manzana'
    ORDER BY id_producto DESC
);

DECLARE @banana INT =
(
    SELECT TOP 1 id_producto
    FROM productos.Producto
    WHERE nombre='Banana'
    ORDER BY id_producto DESC
);

-- 🔥 Asociar productos al stock
UPDATE productos.Producto
SET id_stock = @stockRamos
WHERE id_producto = @manzana;

UPDATE productos.Producto
SET id_stock = @stockSanJusto
WHERE id_producto = @banana;

-- 🔥 Bajar el stock mínimo para provocar faltantes
UPDATE productos.Stock
SET stock_minimo = 600;  -- mayor que cualquier lote