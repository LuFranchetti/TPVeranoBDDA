/*
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas - Comisión 2343 Verano
Grupo:
- Leonel Cespedes
- Luciana Franchetti

Archivo: Testing de Stored Procedures
Base de datos: Com2343
*/

USE Com2343
GO


/*****************************************************************
***********************  TABLA: SUCURSAL  ************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaSucursal','ModificarSucursal','BajaSucursal')

----------------------- ALTA SUCURSAL

-- Caso correcto
EXEC csp.AltaSucursal 'Sucursal Centro', 'Av. Rivadavia 1234'

-- Caso con múltiples errores
EXEC csp.AltaSucursal '', 'a'

----------------------- MODIFICAR SUCURSAL

-- Correcto
EXEC csp.ModificarSucursal 1, 'Sucursal Centro Modificada', 'Nueva Dirección 999'

-- Error (ID inexistente + nombre vacío)
EXEC csp.ModificarSucursal 999, '', ''


----------------------- BAJA SUCURSAL

-- Intentar eliminar sucursal con stock (puede fallar si existe stock)
EXEC csp.BajaSucursal 1

-- Eliminar sucursal inexistente
EXEC csp.BajaSucursal 999



/*****************************************************************
************************  TABLA: STOCK  ***************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaStock','ModificarStock','BajaStock')

----------------------- ALTA STOCK

-- Caso correcto (requiere que exista sucursal 1)
EXEC csp.AltaStock 1, 10,  '2000-01-01'

-- Caso con múltiples errores
EXEC csp.AltaStock 999, -5, '2050-01-01'


----------------------- MODIFICAR STOCK

-- Caso correcto
EXEC csp.ModificarStock 1, 20, '2000-01-01'

-- Caso con errores múltiples
EXEC csp.ModificarStock 999, -10, '2050-01-01'


----------------------- BAJA STOCK

-- Caso correcto
EXEC csp.BajaStock 1

-- Caso con error
EXEC csp.BajaStock 999


/*****************************************************************
***********************  TABLA: TEMPORADA  ************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaTemporada','ModificarTemporada','BajaTemporada')

----------------------- ALTA TEMPORADA

-- Caso correcto
EXEC csp.AltaTemporada 'Verano 2026', 'Temporada alta verano', '2026-01-01', '2026-03-31'

-- Caso con múltiples errores
EXEC csp.AltaTemporada '', '', '2026-05-01', '2026-01-01'


----------------------- MODIFICAR TEMPORADA

-- Caso correcto
EXEC csp.ModificarTemporada 1, 'Verano 2026 Modificada', 'Temporada extendida', '2026-01-01', '2026-04-15'

-- Caso con errores múltiples (ID inexistente + fechas inválidas)
EXEC csp.ModificarTemporada 999, '', '', '2026-06-01', '2026-01-01'


----------------------- BAJA TEMPORADA

-- Caso correcto
EXEC csp.BajaTemporada 1

-- Caso con error (ID inexistente)
EXEC csp.BajaTemporada 999



/*****************************************************************
***********************  TABLA: CATEGORIA  ************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaCategoria','ModificarCategoria','BajaCategoria')

----------------------- ALTA CATEGORIA

-- Caso correcto
TRUNCATE TABLE ct.Categoria;
EXEC csp.AltaCategoria 'Calzado', 25.50

-- Caso con múltiples errores
EXEC csp.AltaCategoria '', -10


----------------------- MODIFICAR CATEGORIA

-- Caso correcto
EXEC csp.ModificarCategoria 1, 'Calzado Deportivo', 30.00

-- Caso con errores múltiples (ID inexistente + margen inválido)
EXEC csp.ModificarCategoria 999, '', -5


----------------------- BAJA CATEGORIA

-- Caso correcto
EXEC csp.BajaCategoria 1

-- Caso con error
EXEC csp.BajaCategoria 999


/*****************************************************************
***********************  TABLA: PROVEEDOR  ************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaProveedor','ModificarProveedor','BajaProveedor')

----------------------- ALTA PROVEEDOR

-- Caso correcto
TRUNCATE TABLE ct.Proveedor;
EXEC csp.AltaProveedor 'Juan', 'Perez', '1122334455', '20-12345678-3'

-- Caso con errores
EXEC csp.AltaProveedor '', '', NULL, '20-12345678-3'


----------------------- BAJA PROVEEDOR

-- Intentar eliminar proveedor con producto asociado (puede fallar)
EXEC csp.BajaProveedor 1

-- Proveedor inexistente
EXEC csp.BajaProveedor 999



/*****************************************************************
***********************  TABLA: PRODUCTO  *************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaProducto','BajaProducto')

----------------------- ALTA PRODUCTO

-- Caso correcto (requiere que existan los IDs referenciados)
select * from ct.Proveedor
select * from ct.Categoria

EXEC csp.AltaProducto 
'Lechuga', 
'Lechuga fresca', 
'granel', 
'hoja verde', 
10, 
1, 
NULL, 
NULL, 
1


-- Caso con múltiples errores
EXEC csp.AltaProducto 
'', 
'', 
'otro', 
'otro', 
-5, 
999, 
999, 
999, 
999


----------------------- BAJA PRODUCTO

-- Caso correcto
EXEC csp.BajaProducto 1

-- Caso error
EXEC csp.BajaProducto 999


/*****************************************************************
***********************  TABLA: LISTA_PRECIO  *********************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaListaPrecio','BajaListaPrecio')

----------------------- ALTA LISTA PRECIO
select * from ct.Proveedor
select * from ct.Categoria
select * from ct.Producto

-- Caso correcto
EXEC csp.AltaListaPrecio 1, 2, 2, 'json'

-- Caso con errores múltiples
EXEC csp.AltaListaPrecio 1, 999, 999, 'xml'


----------------------- BAJA LISTA PRECIO

-- Caso correcto
EXEC csp.BajaListaPrecio 1, 1, 1

-- Caso error
EXEC csp.BajaListaPrecio 999, 1, 1



/*****************************************************************
************************  TABLA: LOTE  *****************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaLote','ModificarLote','BajaLote')

----------------------- ALTA LOTE
select * from ct.Producto

-- Caso correcto
EXEC csp.AltaLote 1, 1, 100, 250.50, '2026-01-01', '2026-03-01'

-- Caso con múltiples errores
EXEC csp.AltaLote 1, 999, -10, -5, '2026-05-01', '2026-01-01'


----------------------- MODIFICAR LOTE

-- Caso correcto
EXEC csp.ModificarLote 1, 1, 200, 300.00, '2026-01-01', '2026-04-01'

-- Caso error
EXEC csp.ModificarLote 999, 1, 10, 10, '2026-01-01', '2026-01-01'


----------------------- BAJA LOTE

-- Caso correcto
EXEC csp.BajaLote 1, 1

-- Caso error
EXEC csp.BajaLote 999, 1


/*****************************************************************
************************  TABLA: CLIENTE  *************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaCliente','ModificarCliente','BajaCliente')

----------------------- ALTA CLIENTE

-- Caso correcto
EXEC csp.AltaCliente 'Maria', 'Lopez', '11223344', 'Av Siempre Viva 123', 'registrado'

-- Caso con errores múltiples
EXEC csp.AltaCliente '', '', NULL, NULL, 'otro'


----------------------- MODIFICAR CLIENTE

-- Caso correcto
EXEC csp.ModificarCliente 1, 'Maria', 'Gomez', '11999999', 'Nueva Dir 555', 'consumidor final'

-- Caso error
EXEC csp.ModificarCliente 999, 'Test', 'Test', NULL, NULL, 'registrado'


----------------------- BAJA CLIENTE

-- Caso correcto
EXEC csp.BajaCliente 1

-- Caso error
EXEC csp.BajaCliente 999



/*****************************************************************
***********************  TABLA: CAPACITADOR  **********************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaCapacitador','ModificarCapacitador','BajaCapacitador')

----------------------- ALTA CAPACITADOR

-- Caso correcto
EXEC csp.AltaCapacitador 'Carlos', 'Perez'

-- Caso con errores
EXEC csp.AltaCapacitador '', ''


----------------------- MODIFICAR CAPACITADOR

-- Caso correcto
EXEC csp.ModificarCapacitador 1, 'Carlos', 'Gonzalez'

-- Caso error
EXEC csp.ModificarCapacitador 999, 'Test', 'Test'


----------------------- BAJA CAPACITADOR

-- Caso correcto
EXEC csp.BajaCapacitador 1

-- Caso error
EXEC csp.BajaCapacitador 999


/*****************************************************************
***********************  TABLA: CERTIFICADO  **********************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaCertificado','BajaCertificado')

----------------------- ALTA CERTIFICADO

-- Caso correcto (requiere que exista capacitador 1)
EXEC csp.AltaCertificado 1, '2025-01-01'

-- Caso con errores
EXEC csp.AltaCertificado 999, '2050-01-01'


----------------------- BAJA CERTIFICADO

-- Caso correcto
EXEC csp.BajaCertificado 1

-- Caso error
EXEC csp.BajaCertificado 999



/*****************************************************************
************************  TABLA: VENDEDOR  ************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaVendedor','BajaVendedor')

----------------------- ALTA VENDEDOR

-- Caso correcto
EXEC csp.AltaVendedor 1, 'Pedro', 'Lopez', 1, 1

-- Caso con errores múltiples
EXEC csp.AltaVendedor 1, 'Pedro', 'Lopez', 999, 999


----------------------- BAJA VENDEDOR

-- Caso correcto
EXEC csp.BajaVendedor 1, 1

-- Caso error
EXEC csp.BajaVendedor 999, 1


/*****************************************************************
************************  TABLA: VENTA  ***************************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaVenta','BajaVenta')

----------------------- ALTA VENTA
select * from ct.Vendedor
-- Caso correcto
EXEC csp.AltaVenta '2010-12-31', 'presencial', 'propio', 1, 1, NULL

-- Caso con errores múltiples
EXEC csp.AltaVenta '2050-01-01', 'otra', 'otro', 999, 999, 999


----------------------- BAJA VENTA

-- Caso correcto
EXEC csp.BajaVenta 1

-- Caso error
EXEC csp.BajaVenta 999



/*****************************************************************
***********************  TABLA: DETALLE_VENTA  ********************
*****************************************************************/

SELECT name 
FROM sys.procedures
WHERE name IN ('AltaDetalleVenta','BajaDetalleVenta')

----------------------- ALTA DETALLE

-- Caso correcto
EXEC csp.AltaDetalleVenta 1, 1, 1, 5, 150.00

-- Caso con errores múltiples
EXEC csp.AltaDetalleVenta 999, 999, 999, -5, -10


----------------------- BAJA DETALLE

-- Caso correcto
EXEC csp.BajaDetalleVenta 1

-- Caso error
EXEC csp.BajaDetalleVenta 999