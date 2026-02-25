/*
=========================================================
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas - Comisión 2343 Verano
Grupo:
- Leonel Cespedes
- Luciana Franchetti

Entrega 5 – Procesos de Importación
Archivo procesado: Reporte de Mermas

Arquitectura implementada:

1) STAGING (zona sucia)
2) PROCESAMIENTO
3) TABLAS FINALES

Flujo:
Archivo CSV → staging → SP procesamiento → ct.Merma

Archivo CSV
     ↓
staging.MermasRaw
     ↓
csp.ProcesarMermas
     ↓
ct.Merma   ← (tabla final histórica)
=========================================================
*/

USE Com2343;
GO

CREATE OR ALTER PROCEDURE csp.ProcesarMermas
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @registros_staging INT = 0;
    DECLARE @registros_insertados INT = 0;
    DECLARE @registros_error INT = 0;

    BEGIN TRY

        -- Cantidad total recibida
        SELECT @registros_staging = COUNT(*) 
        FROM staging.MermasRaw;

        -- ====================================================
        -- ERRORES: Fecha inválida
        -- ====================================================
        INSERT INTO staging.ErroresMermas (descripcion, fila_producto, fila_sucursal)
        SELECT 'Fecha inválida', m.producto, m.sucursal
        FROM staging.MermasRaw m
        WHERE TRY_CONVERT(DATE, m.fecha, 103) IS NULL;

        -- ====================================================
        -- ERRORES: Cantidad inválida
        -- ====================================================
        INSERT INTO staging.ErroresMermas (descripcion, fila_producto, fila_sucursal)
        SELECT 'Cantidad inválida', m.producto, m.sucursal
        FROM staging.MermasRaw m
        WHERE TRY_CONVERT(INT, m.cantidad) IS NULL;

        -- ====================================================
        -- ERRORES: Producto inexistente
        -- ====================================================
        INSERT INTO staging.ErroresMermas (descripcion, fila_producto, fila_sucursal)
        SELECT 'Producto inexistente', m.producto, m.sucursal
        FROM staging.MermasRaw m
        WHERE NOT EXISTS (
            SELECT 1 FROM ct.Producto p
            WHERE p.nombre = m.producto
        );

        -- ====================================================
        -- ERRORES: Sucursal inexistente
        -- ====================================================
        INSERT INTO staging.ErroresMermas (descripcion, fila_producto, fila_sucursal)
        SELECT 'Sucursal inexistente', m.producto, m.sucursal
        FROM staging.MermasRaw m
        WHERE NOT EXISTS (
            SELECT 1 FROM ct.Sucursal s
            WHERE s.nombre = m.sucursal
        );

        -- Contar errores
        SELECT @registros_error = COUNT(*) 
        FROM staging.ErroresMermas
        WHERE fecha >= DATEADD(MINUTE,-5,GETDATE());

        -- ====================================================
        -- INSERTAR REGISTROS VÁLIDOS (HISTÓRICO)
        -- ====================================================
        INSERT INTO ct.Merma (id_producto, id_sucursal, fecha, cantidad)
        SELECT 
            p.id_producto,
            s.id_sucursal,
            TRY_CONVERT(DATE, m.fecha, 103),
            TRY_CONVERT(INT, m.cantidad)
        FROM staging.MermasRaw m
        JOIN ct.Producto p ON p.nombre = m.producto
        JOIN ct.Sucursal s ON s.nombre = m.sucursal
        WHERE 
            TRY_CONVERT(DATE, m.fecha, 103) IS NOT NULL
            AND TRY_CONVERT(INT, m.cantidad) IS NOT NULL
            AND NOT EXISTS (
                SELECT 1 
                FROM ct.Merma me
                WHERE me.id_producto = p.id_producto
                AND me.id_sucursal = s.id_sucursal
                AND me.fecha = TRY_CONVERT(DATE, m.fecha, 103)
            );

        SET @registros_insertados = @@ROWCOUNT;

        -- ====================================================
        -- LOG DE IMPORTACIÓN
        -- ====================================================
        INSERT INTO staging.LogImportacionMermas
        (registros_staging, registros_insertados, registros_error)
        VALUES (@registros_staging, @registros_insertados, @registros_error);

        -- ====================================================
        -- LIMPIAR STAGING
        -- ====================================================
        TRUNCATE TABLE staging.MermasRaw;

    END TRY
    BEGIN CATCH
        INSERT INTO staging.ErroresMermas (descripcion)
        VALUES (ERROR_MESSAGE());
    END CATCH

END
GO

-- IMPORTACIÓN DEL ARCHIVO
BULK INSERT staging.MermasRaw
FROM 'C:\Importaciones\mermas.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO

-- ====================================================
-- UPSERT PRODUCTOS (Insertar si no existen)
-- ====================================================

INSERT INTO ct.Categoria (nombre, margen_ganancia)
VALUES ('General', 30);


INSERT INTO ct.Producto
(nombre, descripcion, forma_comercializacion, tipo_producto_agricola, vida_util, id_categoria)
SELECT DISTINCT
    m.producto,
    'Importado desde archivo de mermas',
    'unidad',
    'hoja verde',
    30,
    1
FROM staging.MermasRaw m
WHERE NOT EXISTS (
    SELECT 1
    FROM ct.Producto p
    WHERE p.nombre = m.producto
);


-- ====================================================
-- UPSERT SUCURSALES (Insertar si no existen)
-- ====================================================

INSERT INTO ct.Sucursal (nombre, direccion)
SELECT DISTINCT
    m.sucursal,
    'Sucursal importada'
FROM staging.MermasRaw m
WHERE NOT EXISTS (
    SELECT 1
    FROM ct.Sucursal s
    WHERE s.nombre = m.sucursal
);