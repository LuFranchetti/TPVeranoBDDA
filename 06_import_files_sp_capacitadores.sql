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

CREATE OR ALTER PROCEDURE csp.ProcesarCapacitadores
    @rutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @registros_staging INT = 0;
    DECLARE @registros_insertados INT = 0;
    DECLARE @registros_actualizados INT = 0;
    DECLARE @registros_error INT = 0;

    BEGIN TRY

        -- ==========================================
        -- TABLA TEMPORAL (STAGING INTERNO)
        -- ==========================================

        IF OBJECT_ID('tempdb..#CapacitadoresRaw') IS NOT NULL
            DROP TABLE #CapacitadoresRaw;

        CREATE TABLE #CapacitadoresRaw (
            numero_registro VARCHAR(100),
            nombre_completo VARCHAR(200),
            telefono VARCHAR(50),
            mail VARCHAR(200)
        );

        -- ==========================================
        -- BULK INSERT DINÁMICO
        -- ==========================================

        DECLARE @sql NVARCHAR(MAX);

        SET @sql = '
        BULK INSERT #CapacitadoresRaw
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001'',
            TABLOCK
        );';

        EXEC(@sql);

        SELECT @registros_staging = COUNT(*) FROM #CapacitadoresRaw;

        -- ==========================================
        -- VALIDACIONES (ERRORES PERMANENTES)
        -- ==========================================

        INSERT INTO ct.ErroresCapacitadores (descripcion, numero_registro)
        SELECT 'Número de registro vacío', numero_registro
        FROM #CapacitadoresRaw
        WHERE numero_registro IS NULL OR numero_registro = '';

        SELECT @registros_error = @@ROWCOUNT;

        -- ==========================================
        -- UPDATE (UPSERT PARTE 1)
        -- ==========================================

        UPDATE c
        SET 
            c.telefono = s.telefono,
            c.mail = s.mail
        FROM ct.Capacitador c
        JOIN #CapacitadoresRaw s
            ON c.numero_registro = s.numero_registro;

        SET @registros_actualizados = @@ROWCOUNT;

        -- ==========================================
        -- INSERT (UPSERT PARTE 2)
        -- ==========================================

        INSERT INTO ct.Capacitador
        (numero_registro, nombre, apellido, telefono, mail)
        SELECT
            s.numero_registro,
            LEFT(s.nombre_completo, CHARINDEX(' ', s.nombre_completo + ' ') - 1),
            SUBSTRING(
                s.nombre_completo,
                CHARINDEX(' ', s.nombre_completo + ' ') + 1,
                200
            ),
            s.telefono,
            s.mail
        FROM #CapacitadoresRaw s
        WHERE s.numero_registro IS NOT NULL
        AND s.numero_registro <> ''
        AND NOT EXISTS (
            SELECT 1
            FROM ct.Capacitador c
            WHERE c.numero_registro = s.numero_registro
        );

        SET @registros_insertados = @@ROWCOUNT;

        -- ==========================================
        -- LOG PERMANENTE
        -- ==========================================

        INSERT INTO ct.LogImportacionCapacitadores
        (registros_staging, registros_actualizados, registros_insertados, registros_error)
        VALUES (@registros_staging, @registros_actualizados, @registros_insertados, @registros_error);

        -- ==========================================
        -- 7RESULTADO
        -- ==========================================

        SELECT 
            @registros_staging AS registros_recibidos,
            @registros_actualizados AS registros_actualizados,
            @registros_insertados AS registros_insertados,
            @registros_error AS registros_error;

    END TRY
    BEGIN CATCH
        INSERT INTO ct.ErroresCapacitadores (descripcion)
        VALUES (ERROR_MESSAGE());
    END CATCH

END
GO
