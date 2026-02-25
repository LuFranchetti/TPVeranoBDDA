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
    DECLARE @registros_actualizados INT = 0;
    DECLARE @registros_error INT = 0;

    BEGIN TRY

        -- =====================================
        -- 1️⃣ CONTAR REGISTROS EN STAGING
        -- =====================================
        SELECT @registros_staging = COUNT(*) 
        FROM staging.PreciosRaw;


        -- =====================================
        -- 2️⃣ VALIDACIONES BÁSICAS
        -- =====================================

        -- Precio mayorista inválido
        INSERT INTO staging.ErroresPrecios (descripcion, especie, variedad)
        SELECT 'Precio mayorista inválido', especie, variedad
        FROM staging.PreciosRaw
        WHERE TRY_CONVERT(DECIMAL(18,2), precio_mayorista) IS NULL
              AND precio_mayorista IS NOT NULL;


        -- Precio modal inválido
        INSERT INTO staging.ErroresPrecios (descripcion, especie, variedad)
        SELECT 'Precio modal inválido', especie, variedad
        FROM staging.PreciosRaw
        WHERE TRY_CONVERT(DECIMAL(18,2), precio_modal) IS NULL
              AND precio_modal IS NOT NULL;


        -- Contar errores recientes
        SELECT @registros_error = COUNT(*)
        FROM staging.ErroresPrecios
        WHERE fecha >= DATEADD(MINUTE,-5,GETDATE());


        -- =====================================
        -- 3️⃣ UPDATE (UPSERT PARTE 1)
        -- =====================================
        UPDATE p
        SET
            p.precio_mayorista = TRY_CONVERT(DECIMAL(18,2), r.precio_mayorista),
            p.precio_modal = TRY_CONVERT(DECIMAL(18,2), r.precio_modal),
            p.precio_minimo = TRY_CONVERT(DECIMAL(18,2), r.precio_minimo),
            p.precio_mayorista_kg = TRY_CONVERT(DECIMAL(18,2), r.precio_mayorista_kg),
            p.precio_modal_kg = TRY_CONVERT(DECIMAL(18,2), r.precio_modal_kg),
            p.precio_minimo_kg = TRY_CONVERT(DECIMAL(18,2), r.precio_minimo_kg)
        FROM ct.PrecioMayorista p
        JOIN staging.PreciosRaw r
            ON p.fecha = @fecha
            AND p.tipo_producto = @tipo_producto
            AND p.especie = r.especie
            AND ISNULL(p.variedad,'') = ISNULL(r.variedad,'');

        SET @registros_actualizados = @@ROWCOUNT;


        -- =====================================
        -- 4️⃣ INSERT (UPSERT PARTE 2)
        -- =====================================
        INSERT INTO ct.PrecioMayorista (
            fecha,
            tipo_producto,
            especie,
            variedad,
            procedencia,
            tamanio,
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
            r.especie,
            r.variedad,
            r.procedencia,
            r.tamanio,
            TRY_CONVERT(DECIMAL(18,2), r.precio_mayorista),
            TRY_CONVERT(DECIMAL(18,2), r.precio_modal),
            TRY_CONVERT(DECIMAL(18,2), r.precio_minimo),
            TRY_CONVERT(DECIMAL(18,2), r.precio_mayorista_kg),
            TRY_CONVERT(DECIMAL(18,2), r.precio_modal_kg),
            TRY_CONVERT(DECIMAL(18,2), r.precio_minimo_kg)
        FROM staging.PreciosRaw r
        WHERE NOT EXISTS (
            SELECT 1
            FROM ct.PrecioMayorista p
            WHERE p.fecha = @fecha
              AND p.tipo_producto = @tipo_producto
              AND p.especie = r.especie
              AND ISNULL(p.variedad,'') = ISNULL(r.variedad,'')
        );

        SET @registros_insertados = @@ROWCOUNT;


        -- =====================================
        -- 5️⃣ LOG
        -- =====================================
        INSERT INTO staging.LogImportacionPrecios
        (fecha_archivo, tipo_producto, registros_staging,
         registros_actualizados, registros_insertados, registros_error)
        VALUES (@fecha, @tipo_producto,
                @registros_staging,
                @registros_actualizados,
                @registros_insertados,
                @registros_error);


        -- =====================================
        -- 6️⃣ LIMPIAR STAGING
        -- =====================================
        TRUNCATE TABLE staging.PreciosRaw;

    END TRY
    BEGIN CATCH
        INSERT INTO staging.ErroresPrecios (descripcion)
        VALUES (ERROR_MESSAGE());
    END CATCH

END
GO



USE Com2343;
GO

BULK INSERT staging.PreciosRaw
FROM 'C:\importaciones\FRUTAS_FEBRERO-26_0\RF250226.csv'
WITH (
    FIRSTROW = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR = '\n',
    CODEPAGE = '65001',
    TABLOCK
);
GO