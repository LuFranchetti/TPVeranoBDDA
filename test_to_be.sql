/*    

	Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
	Componentes del grupo:
		-Leonel Cespedes
		-Luciana Franchetti

    Descripción: 
	Este script contiene consultas que demuestran el
	cumplimiento funcional de los requerimientos A–F.

*/

USE Com2343;
GO


/* =====================================================
A. GESTIÓN DE PRODUCTOS Y PRESENTACIÓN
===================================================== */

/*
A.1 - Verificación de modalidades de comercialización.
Demuestra que el sistema soporta productos por granel
y por unidad, junto con su vida útil y tipo agrícola.
*/

SELECT 
    nombre,
    forma_comercializacion,
    tipo_producto_agricola,
    vida_util
FROM productos.Producto;


/*
A.2 - Productos de estación.
Permite visualizar qué productos están dentro
de una temporada activa según la fecha actual.
*/

SELECT 
    p.nombre AS Producto,
    t.nombre AS Temporada,
    t.fecha_inicio,
    t.fecha_fin
FROM productos.Producto p
INNER JOIN productos.Temporada t
    ON p.id_temporada = t.id_temporada
WHERE CAST(GETDATE() AS DATE) 
      BETWEEN t.fecha_inicio AND t.fecha_fin;



/* =====================================================
B. GESTIÓN DE PROVEEDORES Y LISTAS DE PRECIOS
===================================================== */

/*
B.1 - Relación Producto–Proveedor.
Demuestra que un producto puede estar asociado
a un proveedor y permite visualizar dicha relación.
*/

SELECT 
    p.nombre AS Producto,
    pr.nombre + ' ' + pr.apellido AS Proveedor
FROM productos.Producto p
INNER JOIN proveedores.Proveedor pr
    ON p.id_proveedor = pr.id_proveedor
ORDER BY p.nombre;


/*
B.2 - Comparación de costos recientes.
Permite comparar precios promedio del último mes
para apoyar la toma de decisiones de compra.
*/

SELECT 
    especie AS Producto,
    AVG(precio_mayorista) AS Precio_Promedio_30_Dias
FROM importaciones.PrecioMayorista
WHERE fecha >= DATEADD(DAY,-30,GETDATE())
GROUP BY especie
ORDER BY Precio_Promedio_30_Dias ASC;



/* =====================================================
C. STOCK Y VENCIMIENTOS (LÓGICA FEFO)
===================================================== */

/*
C.1 - Visualización de lotes ordenados por vencimiento.
Demuestra la aplicación del criterio FEFO
(First Expired, First Out).
*/

SELECT 
    p.nombre AS Producto,
    l.id_lote,
    l.fecha_ingreso,
    l.fecha_vencimiento,
    l.cantidad_inicial
FROM productos.Lote l
INNER JOIN productos.Producto p
    ON l.id_producto = p.id_producto
ORDER BY l.fecha_vencimiento ASC;


/*
C.2 - Stock total por sucursal.
Permite visualizar el stock separado por sucursal,
aunque consultable en forma unificada.
*/

SELECT 
    s.nombre AS Sucursal,
    p.nombre AS Producto,
    SUM(l.cantidad_inicial) AS Stock_Total
FROM productos.Lote l
INNER JOIN productos.Producto p
    ON l.id_producto = p.id_producto
INNER JOIN productos.Stock st
    ON p.id_stock = st.id_stock
INNER JOIN productos.Sucursal s
    ON st.id_sucursal = s.id_sucursal
GROUP BY s.nombre, p.nombre
ORDER BY s.nombre, p.nombre;



/* =====================================================
D. AUTOMATIZACIÓN DE PRECIOS DE VENTA
===================================================== */

/*
D.1 - Cálculo de precio sugerido.
Simula la sugerencia automática de precio de venta
basándose en el costo mayorista y el margen de ganancia
definido por categoría.
*/

SELECT 
    p.nombre AS Producto,
    pm.precio_mayorista AS Costo_Actual,
    c.margen_ganancia,
    pm.precio_mayorista * (1 + c.margen_ganancia/100.0) 
        AS Precio_Sugerido
FROM importaciones.PrecioMayorista pm
INNER JOIN productos.Producto p
    ON pm.especie = p.nombre
INNER JOIN productos.Categoria c
    ON p.id_categoria = c.id_categoria
WHERE pm.fecha >= DATEADD(DAY,-7,GETDATE());



/* =====================================================
E. GESTIÓN DE VENTAS Y TRAZABILIDAD
===================================================== */

/*
E.1 - Trazabilidad de ventas por lote.
Demuestra que cada venta registra el lote asociado,
garantizando control de stock y vencimientos.
*/

SELECT 
    v.id_venta,
    s.nombre AS Sucursal,
    p.nombre AS Producto,
    dv.id_lote,
    dv.cantidad,
    dv.precio_unitario
FROM ventas.DetalleVenta dv
INNER JOIN ventas.Venta v
    ON dv.id_venta = v.id_venta
INNER JOIN productos.Producto p
    ON dv.id_producto = p.id_producto
INNER JOIN productos.Sucursal s
    ON v.id_sucursal = s.id_sucursal;


/*
E.2 - Validación de vendedores certificados.
Demuestra que cada vendedor posee un certificado
emitido por un capacitador habilitado.
*/

SELECT 
    v.nombre + ' ' + v.apellido AS Vendedor,
    s.nombre AS Sucursal,
    c.fecha_capacitacion
FROM ventas.Vendedor v
INNER JOIN ventas.Certificado c
    ON v.id_certificado = c.id_certificado
INNER JOIN productos.Sucursal s
    ON v.id_sucursal = s.id_sucursal;



/* =====================================================
F. PROYECCIÓN FUTURA (ESTIMACIONES AGRÍCOLAS)
===================================================== */

/*
F.1 - Evolución histórica de producción por campaña.
Permite analizar tendencias productivas y proyectar
posibles variaciones futuras de precio.
*/

SELECT 
    cultivo,
    campania,
    SUM(produccion) AS Produccion_Total
FROM importaciones.EstimacionAgricola
GROUP BY cultivo, campania
ORDER BY cultivo, campania;