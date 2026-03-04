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
=========================================================
*/

USE Com2343;
GO

CREATE OR ALTER PROCEDURE csp.ProcesarPrecios
    @rutaArchivo NVARCHAR(500),
    @fecha DATE,
    @tipo_producto VARCHAR(20)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @registros_staging INT = 0;
    DECLARE @registros_insertados INT = 0;
    DECLARE @registros_error INT = 0;

    BEGIN TRY

        BEGIN TRAN;

        -- ==========================================
        -- 1 TABLA TEMPORAL
        -- ==========================================

        IF OBJECT_ID('tempdb..#PreciosRaw') IS NOT NULL
            DROP TABLE #PreciosRaw;

        CREATE TABLE #PreciosRaw (
            ESP VARCHAR(200),
            VAR VARCHAR(200),
            PROCEDENCIA VARCHAR(200),
            ENV VARCHAR(50),
            KG VARCHAR(50),
            CAL VARCHAR(50),
            TAM VARCHAR(100),
            GRADO VARCHAR(50),
            MA VARCHAR(50),
            MO VARCHAR(50),
            MI VARCHAR(50),
            MAPK VARCHAR(50),
            MOPK VARCHAR(50),
            MIPK VARCHAR(50)
        );

        -- ==========================================
        -- 2 BULK INSERT DINÁMICO
        -- ==========================================

        DECLARE @sql NVARCHAR(MAX);

        SET @sql = '
        BULK INSERT #PreciosRaw
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001'',
            TABLOCK
        );';

        EXEC(@sql);

        SELECT @registros_staging = COUNT(*) FROM #PreciosRaw;

        -- ==========================================
        -- 3️⃣ INSERT A TABLA FINAL
        -- ==========================================

        INSERT INTO importaciones.PrecioMayorista (
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
        FROM #PreciosRaw r;

        SET @registros_insertados = @@ROWCOUNT;

        -- ==========================================
        -- 4 LOG PERMANENTE
        -- ==========================================

        INSERT INTO importaciones.LogImportacionPrecios
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
            @registros_error
        );

        COMMIT;

        -- ==========================================
        -- 5 RESULTADO
        -- ==========================================

        SELECT 
            @registros_staging AS registros_recibidos,
            @registros_insertados AS registros_insertados;

    END TRY
    BEGIN CATCH

        IF @@TRANCOUNT > 0
            ROLLBACK;

        INSERT INTO importaciones.ErroresPrecios (descripcion)
        VALUES (ERROR_MESSAGE());

    END CATCH
END
GO