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
CREATE OR ALTER PROCEDURE csp.ProcesarCapacitadores
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @registros_staging INT = 0;
    DECLARE @registros_insertados INT = 0;
    DECLARE @registros_actualizados INT = 0;
    DECLARE @registros_error INT = 0;

    BEGIN TRY

        SELECT @registros_staging = COUNT(*) 
        FROM staging.CapacitadoresRaw;

        -- ======================================
        -- VALIDACIONES
        -- ======================================

        INSERT INTO staging.ErroresCapacitadores
        (descripcion, numero_registro)
        SELECT 'Número de registro vacío', numero_registro
        FROM staging.CapacitadoresRaw
        WHERE numero_registro IS NULL OR numero_registro = '';

        SELECT @registros_error = COUNT(*) 
        FROM staging.ErroresCapacitadores
        WHERE fecha >= DATEADD(MINUTE,-5,GETDATE());

        -- ======================================
        -- UPDATE (UPSERT parte 1)
        -- ======================================

        UPDATE c
        SET 
            c.telefono = s.telefono,
            c.mail = s.mail
        FROM ct.Capacitador c
        JOIN staging.CapacitadoresRaw s
            ON c.numero_registro = s.numero_registro;

        SET @registros_actualizados = @@ROWCOUNT;

        -- ======================================
        -- INSERT (UPSERT parte 2)
        -- ======================================

        INSERT INTO ct.Capacitador
        (numero_registro, nombre, apellido, telefono, mail)
        SELECT
            s.numero_registro,
            LEFT(s.nombre_completo, CHARINDEX(' ', s.nombre_completo + ' ') - 1),
            SUBSTRING(s.nombre_completo, 
                      CHARINDEX(' ', s.nombre_completo + ' ') + 1, 
                      200),
            s.telefono,
            s.mail
        FROM staging.CapacitadoresRaw s
        WHERE NOT EXISTS (
            SELECT 1
            FROM ct.Capacitador c
            WHERE c.numero_registro = s.numero_registro
        );

        SET @registros_insertados = @@ROWCOUNT;

        -- ======================================
        -- LOG
        -- ======================================

        INSERT INTO staging.LogImportacionCapacitadores
        (registros_staging, registros_actualizados, registros_insertados, registros_error)
        VALUES (@registros_staging, @registros_actualizados, @registros_insertados, @registros_error);

        TRUNCATE TABLE staging.CapacitadoresRaw;

    END TRY
    BEGIN CATCH
        INSERT INTO staging.ErroresCapacitadores (descripcion)
        VALUES (ERROR_MESSAGE());
    END CATCH
END
GO


BULK INSERT staging.CapacitadoresRaw
FROM 'C:\Importaciones\capacitadores.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);

