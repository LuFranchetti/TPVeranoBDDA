/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
    Componentes del grupo:
        - Leonel Cespedes
        - Luciana Franchetti

    Descripción:
    Creación de Reportes
*/


/*
=========================================================
Reporte de Rentabilidad (XML)

Descripción:
Este procedimiento genera un reporte de rentabilidad 
agrupado por Categoría de Producto.

Calcula:
- Total de Ventas
- Total de Costos (según lote vendido)
- Ganancia Total
- Margen porcentual

Fuente de datos:
DetalleVenta → Lote → Producto → Categoria

Salida:
Devuelve el resultado en formato XML estructurado.
=========================================================
*/

USE Com2343;
GO

CREATE OR ALTER PROCEDURE csp.ReporteRentabilidadXML
AS
BEGIN
    SET NOCOUNT ON;

    SELECT (
        SELECT
            c.nombre AS Categoria,
            
            SUM(dv.precio_unitario * dv.cantidad) AS Total_Ventas,
            
            SUM(l.costo * dv.cantidad) AS Total_Costos,
            
            SUM((dv.precio_unitario - l.costo) * dv.cantidad) AS Ganancia_Total,
            
            CASE 
                WHEN SUM(dv.precio_unitario * dv.cantidad) = 0 THEN 0
                ELSE 
                    (SUM((dv.precio_unitario - l.costo) * dv.cantidad) * 100.0) /
                    SUM(dv.precio_unitario * dv.cantidad)
            END AS Margen_Porcentual

        FROM ct.DetalleVenta dv
        INNER JOIN ct.Lote l
            ON dv.id_lote = l.id_lote
           AND dv.id_producto = l.id_producto
        INNER JOIN ct.Producto p
            ON l.id_producto = p.id_producto
        INNER JOIN ct.Categoria c
            ON p.id_categoria = c.id_categoria

        GROUP BY c.nombre

        FOR XML PATH('Categoria'), TYPE
    )
    AS ReporteXML;

END
GO


SELECT COUNT(*) 
FROM ct.DetalleVenta;


-- Ejecución del reporte
EXEC csp.ReporteRentabilidadXML;


USE Com2343;
GO

/*
=========================================================
SP: csp.AlertaVencimientosXML
Descripción:
Genera un reporte en formato XML con los lotes que
vencen dentro de los próximos X días desde una fecha base.

Parámetros:
- @dias: cantidad de días hacia adelante (default 3)
- @fecha_base: fecha desde la cual calcular (default hoy)

Devuelve:
XML con listado de productos y sus lotes próximos a vencer.
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.AlertaVencimientosXML
    @dias INT = 3,
    @fecha_base DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;

    IF @fecha_base IS NULL
        SET @fecha_base = CAST(GETDATE() AS DATE);

    SELECT CAST(
        (
            SELECT
                p.nombre AS Producto,
                l.id_lote AS Lote,
                l.cantidad_inicial AS Cantidad_Inicial,
                l.fecha_ingreso AS Fecha_Ingreso,
                l.fecha_vencimiento AS Fecha_Vencimiento,
                DATEDIFF(DAY, @fecha_base, l.fecha_vencimiento) AS Dias_Restantes
            FROM ct.Lote l
            INNER JOIN ct.Producto p
                ON l.id_producto = p.id_producto
            WHERE l.fecha_vencimiento BETWEEN @fecha_base
                                          AND DATEADD(DAY, @dias, @fecha_base)
            ORDER BY l.fecha_vencimiento
            FOR XML PATH('Lote'), ROOT('AlertaVencimientos'), TYPE
        ) AS XML
    );
END
GO


USE Com2343;
GO

/*
=========================================================
SP: csp.RankingProveedores
Descripción:
Obtiene los 5 proveedores con mejor precio promedio
por categoría en el último mes.

Criterio:
- Se consideran precios de los últimos 30 días.
- Se agrupa por proveedor y categoría.
- Se ordena por precio promedio ascendente.
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.RankingProveedores
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @fecha_base DATE = CAST(GETDATE() AS DATE);

    SELECT TOP 5
        c.nombre AS Categoria,
        pr.nombre + ' ' + pr.apellido AS Proveedor,
        AVG(pm.precio_mayorista) AS Precio_Promedio
    FROM ct.PrecioMayorista pm
    INNER JOIN ct.Producto p
        ON p.nombre = pm.especie
    INNER JOIN ct.Categoria c
        ON p.id_categoria = c.id_categoria
    INNER JOIN ct.Proveedor pr
        ON p.id_proveedor = pr.id_proveedor
    WHERE pm.fecha >= DATEADD(DAY, -30, @fecha_base)
    GROUP BY
        c.nombre,
        pr.nombre,
        pr.apellido
    ORDER BY Precio_Promedio ASC;
END
GO



USE Com2343;
GO

/*
=========================================================
SP: csp.MatrizDesperdicio
Descripción:
Genera una matriz (PIVOT) mostrando la cantidad
de kilos desperdiciados por Producto (filas)
y Sucursal (columnas).
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.MatrizDesperdicio
AS
BEGIN
    SET NOCOUNT ON;

    SELECT *
    FROM
    (
        SELECT 
            p.nombre AS Producto,
            s.nombre AS Sucursal,
            m.cantidad
        FROM ct.Merma m
        INNER JOIN ct.Producto p
            ON m.id_producto = p.id_producto
        INNER JOIN ct.Sucursal s
            ON m.id_sucursal = s.id_sucursal
    ) AS Fuente
    PIVOT
    (
        SUM(cantidad)
        FOR Sucursal IN ([Sucursal Centro])
    ) AS TablaPivot;
END
GO



USE Com2343;
GO

/*
=========================================================
SP: csp.InformeFaltantes
Descripción:
Indica qué productos deben reponerse comparando
el stock actual (suma de lotes) contra el
stock mínimo configurado por sucursal.

Criterio:
Si stock_actual < stock_minimo → Reponer.
=========================================================
*/
CREATE OR ALTER PROCEDURE csp.InformeFaltantes
AS
BEGIN
    SET NOCOUNT ON;

    SELECT
        s.nombre AS Sucursal,
        p.nombre AS Producto,
        ISNULL(SUM(l.cantidad_inicial), 0) AS Stock_Actual,
        st.stock_minimo AS Stock_Minimo,
        (st.stock_minimo - ISNULL(SUM(l.cantidad_inicial), 0)) AS Cantidad_A_Reponer
    FROM ct.Stock st
    INNER JOIN ct.Sucursal s
        ON st.id_sucursal = s.id_sucursal
    INNER JOIN ct.Producto p
        ON p.id_stock = st.id_stock
    LEFT JOIN ct.Lote l
        ON l.id_producto = p.id_producto
    GROUP BY
        s.nombre,
        p.nombre,
        st.stock_minimo
    HAVING ISNULL(SUM(l.cantidad_inicial), 0) < st.stock_minimo;
END
GO


