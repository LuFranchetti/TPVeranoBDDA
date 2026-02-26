/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
	Componentes del grupo:
		-Leonel Cespedes
		-Luciana Franchetti


    Descripción: Script de pruebas de generacion de los reportes.
*/



/*
=========================================================
-- Probar el Reporte de Rentabilidad (XML)
=========================================================
*/
USE Com2343


EXEC csp.AltaSucursal 
    @nombre = 'Sucursal Centro',
    @direccion = 'Av Siempre Viva 123';


DECLARE @fecha DATETIME = GETDATE();

EXEC csp.AltaStock
    @id_sucursal = 1,
    @stock_minimo = 50,
    @fecha_ultima_actualizacion = @fecha;

EXEC csp.AltaTemporada
    @nombre = 'Verano',
    @descripcion = 'Temporada de calor',
    @fecha_inicio = '2026-01-01',
    @fecha_fin = '2026-03-31';

EXEC csp.AltaCategoria
    @nombre = 'Frutas',
    @margen_ganancia = 30;

EXEC csp.AltaProveedor
    @nombre = 'Juan',
    @apellido = 'Perez',
    @telefono = '12345678',
    @cuit = '20-12345678-9';

EXEC csp.AltaProducto
    @nombre = 'Manzana',
    @descripcion = 'Manzana roja',
    @forma_comercializacion = 'granel',
    @tipo_producto_agricola = 'hoja verde',
    @vida_util = 30,
    @id_categoria = 1,
    @id_stock = 1,
    @id_temporada = 1,
    @id_proveedor = 1;

DECLARE @fecha2 DATETIME;
SET @fecha2 = GETDATE();

DECLARE @fechaVenc DATE;
SET @fechaVenc = DATEADD(DAY, 10, @fecha2);

EXEC csp.AltaLote
    @id_lote = 1,
    @id_producto = 1,
    @cantidad_inicial = 100,
    @costo = 500,
    @fecha_ingreso = @fecha2,
    @fecha_vencimiento = @fechaVenc;


EXEC csp.AltaCapacitador
    @numero_registro = 'REG123',
    @nombre = 'Carlos',
    @apellido = 'Gomez';

DECLARE @fecha3 DATETIME;
SET @fecha3 = GETDATE();

EXEC csp.AltaCertificado
    @id_capacitador = 1,
    @fecha_capacitacion = @fecha3;

EXEC csp.AltaVendedor
    @id_vendedor = 1,
    @nombre = 'Ana',
    @apellido = 'Lopez',
    @id_sucursal = 1,
    @id_certificado = 1;

EXEC csp.AltaCliente
    @nombre = 'Pedro',
    @apellido = 'Martinez',
    @telefono = '1111111',
    @direccion = 'Calle 456',
    @tipo = 'registrado';

DECLARE @fecha4 DATETIME;
SET @fecha4 = GETDATE();

EXEC csp.AltaVenta
    @fecha = @fecha4,
    @modalidad = 'presencial',
    @canal = 'propio',
    @id_vendedor = 1,
    @id_sucursal = 1,
    @id_cliente = 1;

DECLARE @fecha5 DATETIME;
SET @fecha5 = GETDATE();

EXEC csp.AltaVenta
    @fecha = @fecha5,
    @modalidad = 'presencial',
    @canal = 'propio',
    @id_vendedor = 1,
    @id_sucursal = 1,
    @id_cliente = 1;

EXEC csp.AltaDetalleVenta
    @id_venta = 1,
    @id_lote = 1,
    @id_producto = 1,
    @cantidad = 20,
    @precio_unitario = 800;


-- Ejecución del reporte
/*
Ese XML está diciendo:
La categoría Frutas vendió 16.000
Costó 10.000
Ganó 6.000
Tiene un margen del 37,5%
*/
EXEC csp.ReporteRentabilidadXML;



/*
=========================================================
-- Probar el Reporte de Alerta de vencimientos.
=========================================================
*/

--Caso 1 – próximos 15 días (traer mi lote)
EXEC csp.AlertaVencimientosXML @dias = 15;





/*
=========================================================
-- Probar el Reporte de Ranking de Proveedores
=========================================================
*/
DECLARE @fechaPM1 DATE;
SET @fechaPM1 = GETDATE();

EXEC csp.AltaPrecioMayorista
    @fecha = @fechaPM1,
    @tipo_producto = 'fruta',
    @especie = 'Manzana',
    @precio_mayorista = 700;


DECLARE @fechaPM2 DATE;
SET @fechaPM2 = DATEADD(DAY, -5, GETDATE());

EXEC csp.AltaPrecioMayorista
    @fecha = @fechaPM2,
    @tipo_producto = 'fruta',
    @especie = 'Manzana',
    @precio_mayorista = 650;


DECLARE @fechaPM3 DATE;
SET @fechaPM3 = DATEADD(DAY, -10, GETDATE());

EXEC csp.AltaPrecioMayorista
    @fecha = @fechaPM3,
    @tipo_producto = 'fruta',
    @especie = 'Manzana',
    @precio_mayorista = 720;


EXEC csp.RankingProveedores;




/*
=========================================================
-- Probar el Reporte de Matriz de desperdicios
=========================================================
*/
DECLARE @fechaMerma DATE;
SET @fechaMerma = GETDATE();

EXEC csp.AltaMerma
    @id_producto = 1,
    @id_sucursal = 1,
    @fecha = @fechaMerma,
    @cantidad = 25;

EXEC csp.AltaMerma
    @id_producto = 1,
    @id_sucursal = 1,
    @fecha = @fechaMerma,
    @cantidad = 15;


EXEC csp.MatrizDesperdicio;


/*
=========================================================
-- Probar el Reporte de Informe de faltantes
=========================================================
*/
UPDATE ct.Stock
SET stock_minimo = 200
WHERE id_sucursal = 1;

EXEC csp.InformeFaltantes;