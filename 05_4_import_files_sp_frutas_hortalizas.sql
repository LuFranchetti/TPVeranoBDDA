/*
=========================================================
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas
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

CREATE OR ALTER PROCEDURE csp.ProcesarPrecios
    @fecha DATE,
    @tipo_producto VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @registros_staging INT = 0;
    DECLARE @registros_insertados INT = 0;

    BEGIN TRY

        BEGIN TRAN;

        -----------------------------------
        -- 1️⃣ Contar registros en staging
        -----------------------------------
        SELECT @registros_staging = COUNT(*)
        FROM staging.PreciosRaw;

        PRINT 'Registros en staging: ' + CAST(@registros_staging AS VARCHAR);

        -----------------------------------
        -- 2️⃣ INSERT directo (sin UPSERT)
        -----------------------------------
        INSERT INTO ct.PrecioMayorista (
            fecha,
            tipo_producto,
            especie,
            variedad,
            procedencia,
            envase,
            kg,
            calidad,
            tamanio,
            grado,
            precio_mayorista,
            precio_modal,
            precio_minimo,
            precio_mayorista_kg,
            precio_modal_kg,
            precio_minimo_kg
        )
        SELECT
            @fecha,
            @tipo_producto,
            r.ESP,
            r.VAR,
            r.PROCEDENCIA,
            r.ENV,
            TRY_CONVERT(DECIMAL(10,2), REPLACE(r.KG, ',', '.')),
            r.CAL,
            r.TAM,
            r.GRADO,
            TRY_CONVERT(DECIMAL(18,2), REPLACE(r.MA, ',', '.')),
            TRY_CONVERT(DECIMAL(18,2), REPLACE(r.MO, ',', '.')),
            TRY_CONVERT(DECIMAL(18,2), REPLACE(r.MI, ',', '.')),
            TRY_CONVERT(DECIMAL(18,2), REPLACE(r.MAPK, ',', '.')),
            TRY_CONVERT(DECIMAL(18,2), REPLACE(r.MOPK, ',', '.')),
            TRY_CONVERT(DECIMAL(18,2), REPLACE(r.MIPK, ',', '.'))
        FROM staging.PreciosRaw r;

        SET @registros_insertados = @@ROWCOUNT;

        PRINT 'Registros insertados: ' + CAST(@registros_insertados AS VARCHAR);

        -----------------------------------
        -- 3️⃣ Log
        -----------------------------------
        INSERT INTO staging.LogImportacionPrecios
        (
            fecha_archivo,
            tipo_producto,
            registros_staging,
            registros_actualizados,
            registros_insertados,
            registros_error
        )
        VALUES
        (
            @fecha,
            @tipo_producto,
            @registros_staging,
            0,
            @registros_insertados,
            0
        );

        -----------------------------------
        -- 4️⃣ Limpiar staging
        -----------------------------------
        TRUNCATE TABLE staging.PreciosRaw;

        COMMIT;

        PRINT 'SP finalizado correctamente';

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK;

        PRINT 'ERROR DETECTADO';
        PRINT ERROR_MESSAGE();

    END CATCH
END
GO

USE Com2343;
GO

BULK INSERT staging.PreciosRaw
FROM 'C:\importaciones\FRUTAS_FEBRERO-26_0\RF250226.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO



BULK INSERT staging.PreciosRaw
FROM 'C:\importaciones\HORTALIZAS_FEBRERO-26\RH250226.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ';',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO


SELECT COUNT(*) AS RegistrosEnStaging
FROM staging.PreciosRaw;

SELECT *
FROM staging.PreciosRaw;