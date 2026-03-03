/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
	Componentes del grupo:
		-Leonel Cespedes
		-Luciana Franchetti


    Descripción: Insercion de datos
*/

USE Com2343;
GO

/* =====================================================
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
   2️⃣ SUCURSAL + STOCK
===================================================== */

EXEC csp.AltaSucursal 'Sucursal Centro', 'Av Siempre Viva 123';

DECLARE @idSucursal INT =
(SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Sucursal Centro');

EXEC csp.AltaStock @idSucursal, 10, '2026-03-01';


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

EXEC csp.AltaVendedor 1,'Pedro','Martinez',@idSucursal,@idCert;


/* =====================================================
   🔟 VENTAS
===================================================== */

EXEC csp.AltaVenta '2026-03-01','presencial','propio',1,@idSucursal,@idCliente;
EXEC csp.AltaVenta '2026-03-02','domicilio','plataforma',1,@idSucursal,@idCliente;

DECLARE @venta1 INT = (SELECT MIN(id_venta) FROM ventas.Venta);
DECLARE @venta2 INT = (SELECT MAX(id_venta) FROM ventas.Venta);


/* =====================================================
   1️⃣1️⃣ DETALLE VENTAS
===================================================== */

-- Frutas
EXEC csp.AltaDetalleVenta @venta1,1,@idManzana,50,100;
EXEC csp.AltaDetalleVenta @venta1,2,@idBanana,40,90;
EXEC csp.AltaDetalleVenta @venta2,1,@idManzana,30,110;
EXEC csp.AltaDetalleVenta @venta2,2,@idBanana,20,95;

-- Hortalizas
EXEC csp.AltaDetalleVenta @venta1,3,@idLechuga,60,50;
EXEC csp.AltaDetalleVenta @venta2,3,@idLechuga,40,55;

-- Tuberculos
EXEC csp.AltaDetalleVenta @venta1,4,@idPapa,80,50;
EXEC csp.AltaDetalleVenta @venta2,4,@idPapa,40,48;

-- Organicos
EXEC csp.AltaDetalleVenta @venta1,5,@idEspinaca,30,150;
EXEC csp.AltaDetalleVenta @venta2,5,@idEspinaca,20,160;

GO


USE Com2343;
GO

/* =====================================================
   1️⃣ NUEVOS PROVEEDORES
===================================================== */

EXEC csp.AltaProveedor 'Laura','Fernandez','111','20-11111111-1';
EXEC csp.AltaProveedor 'Diego','Ramirez','222','20-22222222-2';
EXEC csp.AltaProveedor 'Sofia','Martinez','333','20-33333333-3';
EXEC csp.AltaProveedor 'Martin','Gomez','444','20-44444444-4';
EXEC csp.AltaProveedor 'Valeria','Lopez','555','20-55555555-5';

DECLARE @prov1 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-11111111-1');
DECLARE @prov2 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-22222222-2');
DECLARE @prov3 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-33333333-3');
DECLARE @prov4 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-44444444-4');
DECLARE @prov5 INT = (SELECT id_proveedor FROM proveedores.Proveedor WHERE cuit='20-55555555-5');


/* =====================================================
   2️⃣ CATEGORIAS EXISTENTES
===================================================== */

DECLARE @catFrutas INT = (SELECT id_categoria FROM productos.Categoria WHERE nombre='Frutas');
DECLARE @catHortalizas INT = (SELECT id_categoria FROM productos.Categoria WHERE nombre='Hortalizas');


/* =====================================================
   3️⃣ PRODUCTOS NUEVOS (ASOCIADOS A CADA PROVEEDOR)
===================================================== */

EXEC csp.AltaProducto 'Naranja_LF','Naranja','unidad','hoja verde',30,@catFrutas,NULL,NULL,@prov1;
EXEC csp.AltaProducto 'Naranja_DR','Naranja','unidad','hoja verde',30,@catFrutas,NULL,NULL,@prov2;
EXEC csp.AltaProducto 'Naranja_SM','Naranja','unidad','hoja verde',30,@catFrutas,NULL,NULL,@prov3;
EXEC csp.AltaProducto 'Naranja_MG','Naranja','unidad','hoja verde',30,@catFrutas,NULL,NULL,@prov4;
EXEC csp.AltaProducto 'Naranja_VL','Naranja','unidad','hoja verde',30,@catFrutas,NULL,NULL,@prov5;


/* =====================================================
   4️⃣ PRECIOS MAYORISTAS (ULTIMOS 30 DIAS)
===================================================== */

DECLARE @fecha1 DATE = DATEADD(DAY,-5,CAST(GETDATE() AS DATE));
DECLARE @fecha2 DATE = DATEADD(DAY,-10,CAST(GETDATE() AS DATE));
DECLARE @fecha3 DATE = DATEADD(DAY,-15,CAST(GETDATE() AS DATE));

-- Proveedor 1 (más barato)
EXEC csp.AltaPrecioMayorista @fecha1,'fruta','Naranja_LF',50;
EXEC csp.AltaPrecioMayorista @fecha2,'fruta','Naranja_LF',55;
EXEC csp.AltaPrecioMayorista @fecha3,'fruta','Naranja_LF',52;

-- Proveedor 2
EXEC csp.AltaPrecioMayorista @fecha1,'fruta','Naranja_DR',60;
EXEC csp.AltaPrecioMayorista @fecha2,'fruta','Naranja_DR',65;
EXEC csp.AltaPrecioMayorista @fecha3,'fruta','Naranja_DR',62;

-- Proveedor 3
EXEC csp.AltaPrecioMayorista @fecha1,'fruta','Naranja_SM',58;
EXEC csp.AltaPrecioMayorista @fecha2,'fruta','Naranja_SM',59;
EXEC csp.AltaPrecioMayorista @fecha3,'fruta','Naranja_SM',61;

-- Proveedor 4
EXEC csp.AltaPrecioMayorista @fecha1,'fruta','Naranja_MG',70;
EXEC csp.AltaPrecioMayorista @fecha2,'fruta','Naranja_MG',72;
EXEC csp.AltaPrecioMayorista @fecha3,'fruta','Naranja_MG',68;

-- Proveedor 5
EXEC csp.AltaPrecioMayorista @fecha1,'fruta','Naranja_VL',54;
EXEC csp.AltaPrecioMayorista @fecha2,'fruta','Naranja_VL',53;
EXEC csp.AltaPrecioMayorista @fecha3,'fruta','Naranja_VL',56;

GO



--Datos Reporte Mermas-*

USE Com2343;
GO

/* =====================================================
   1️⃣ CREAR SEGUNDA SUCURSAL (si no existe)
===================================================== */

IF NOT EXISTS (SELECT 1 FROM productos.Sucursal WHERE nombre = 'Sucursal Norte')
BEGIN
    EXEC csp.AltaSucursal 'Sucursal Norte', 'Av Libertador 500';
END

DECLARE @sucCentro INT = (SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Sucursal Centro');
DECLARE @sucNorte  INT = (SELECT id_sucursal FROM productos.Sucursal WHERE nombre='Sucursal Norte');


/* =====================================================
   2️⃣ OBTENER PRODUCTOS EXISTENTES
===================================================== */

DECLARE @manzana INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Manzana');
DECLARE @banana INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Banana');
DECLARE @lechuga INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Lechuga');
DECLARE @papa INT = (SELECT id_producto FROM productos.Producto WHERE nombre='Papa');


/* =====================================================
   3️⃣ INSERTAR MERMAS EN DISTINTAS SUCURSALES
===================================================== */

-- Sucursal Centro
EXEC csp.AltaMerma @manzana, @sucCentro, '2026-03-01', 10;
EXEC csp.AltaMerma @banana,  @sucCentro, '2026-03-01', 5;
EXEC csp.AltaMerma @lechuga, @sucCentro, '2026-03-02', 7;
EXEC csp.AltaMerma @papa,    @sucCentro, '2026-03-03', 12;

-- Más merma acumulada mismo día (prueba UPDATE interno)
EXEC csp.AltaMerma @manzana, @sucCentro, '2026-03-01', 3;


-- Sucursal Norte
EXEC csp.AltaMerma @manzana, @sucNorte, '2026-03-01', 4;
EXEC csp.AltaMerma @banana,  @sucNorte, '2026-03-02', 9;
EXEC csp.AltaMerma @papa,    @sucNorte, '2026-03-02', 6;

GO