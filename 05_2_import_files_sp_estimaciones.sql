/*
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
*/

USE Com2343;
GO
CREATE OR ALTER PROCEDURE csp.ProcesarEstimaciones
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @registros_staging INT = 0;
    DECLARE @registros_insertados INT = 0;
    DECLARE @registros_actualizados INT = 0;
    DECLARE @registros_error INT = 0;

    BEGIN TRY

        SELECT @registros_staging = COUNT(*) 
        FROM staging.EstimacionesRaw;

        -- ============================
        -- VALIDACIONES
        -- ============================

        INSERT INTO staging.ErroresEstimaciones (descripcion, cultivo, campania, municipio)
        SELECT 'municipio_id inválido', cultivo, campania, municipio_nombre
        FROM staging.EstimacionesRaw
        WHERE TRY_CONVERT(INT, municipio_id) IS NULL;

        INSERT INTO staging.ErroresEstimaciones (descripcion, cultivo, campania, municipio)
        SELECT 'Producción inválida', cultivo, campania, municipio_nombre
        FROM staging.EstimacionesRaw
        WHERE TRY_CONVERT(DECIMAL(18,2), produccion) IS NULL;

        INSERT INTO staging.ErroresEstimaciones (descripcion, cultivo, campania, municipio)
        SELECT 'Superficie inválida', cultivo, campania, municipio_nombre
        FROM staging.EstimacionesRaw
        WHERE TRY_CONVERT(DECIMAL(18,2), superficie_sembrada) IS NULL;

        SELECT @registros_error = COUNT(*) 
        FROM staging.ErroresEstimaciones
        WHERE fecha >= DATEADD(MINUTE,-5,GETDATE());

        -- ============================
        -- UPDATE (UPSERT parte 1)
        -- ============================

        UPDATE e
        SET 
            e.superficie_sembrada = TRY_CONVERT(DECIMAL(18,2), s.superficie_sembrada),
            e.superficie_cosechada = TRY_CONVERT(DECIMAL(18,2), s.superficie_cosechada),
            e.produccion = TRY_CONVERT(DECIMAL(18,2), s.produccion),
            e.rendimiento = TRY_CONVERT(DECIMAL(18,2), s.rendimiento),
            e.municipio_nombre = s.municipio_nombre
        FROM ct.EstimacionAgricola e
        JOIN staging.EstimacionesRaw s
            ON e.cultivo = s.cultivo
            AND e.campania = s.campania
            AND e.municipio_id = TRY_CONVERT(INT, s.municipio_id)
        WHERE 
            TRY_CONVERT(INT, s.municipio_id) IS NOT NULL;

        SET @registros_actualizados = @@ROWCOUNT;

        -- ============================
        -- INSERT (UPSERT parte 2)
        -- ============================

        INSERT INTO ct.EstimacionAgricola (
            cultivo,
            campania,
            municipio_id,
            municipio_nombre,
            superficie_sembrada,
            superficie_cosechada,
            produccion,
            rendimiento
        )
        SELECT 
            s.cultivo,
            s.campania,
            TRY_CONVERT(INT, s.municipio_id),
            s.municipio_nombre,
            TRY_CONVERT(DECIMAL(18,2), s.superficie_sembrada),
            TRY_CONVERT(DECIMAL(18,2), s.superficie_cosechada),
            TRY_CONVERT(DECIMAL(18,2), s.produccion),
            TRY_CONVERT(DECIMAL(18,2), s.rendimiento)
        FROM staging.EstimacionesRaw s
        WHERE 
            TRY_CONVERT(INT, s.municipio_id) IS NOT NULL
            AND NOT EXISTS (
                SELECT 1 
                FROM ct.EstimacionAgricola e
                WHERE e.cultivo = s.cultivo
                AND e.campania = s.campania
                AND e.municipio_id = TRY_CONVERT(INT, s.municipio_id)
            );

        SET @registros_insertados = @@ROWCOUNT;

        -- ============================
        -- LOG
        -- ============================

        INSERT INTO staging.LogImportacionEstimaciones
        (registros_staging, registros_actualizados, registros_insertados, registros_error)
        VALUES (@registros_staging, @registros_actualizados, @registros_insertados, @registros_error);

        -- ============================
        -- LIMPIAR STAGING
        -- ============================

        TRUNCATE TABLE staging.EstimacionesRaw;

    END TRY
    BEGIN CATCH
        INSERT INTO staging.ErroresEstimaciones (descripcion)
        VALUES (ERROR_MESSAGE());
    END CATCH
END
GO



BULK INSERT staging.EstimacionesRaw
FROM 'C:\Importaciones\estimaciones.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO


