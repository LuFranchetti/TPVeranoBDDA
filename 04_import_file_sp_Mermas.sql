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
Archivo CSV → MermasRaw (tabla temporal) → csp.ProcesarMermas → ct.Merma (tabla final productiva)

=========================================================
*/

USE Com2343;
GO

CREATE OR ALTER PROCEDURE csp.ProcesarMermas
    @rutaArchivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @registros_staging INT = 0;
    DECLARE @registros_insertados INT = 0;
    DECLARE @registros_error INT = 0;
    DECLARE @id_categoria INT;

    BEGIN TRY

        -- ==========================================
        -- TABLA TEMPORAL (STAGING INTERNO)
        -- ==========================================

        IF OBJECT_ID('tempdb..#MermasRaw') IS NOT NULL
            DROP TABLE #MermasRaw;

        CREATE TABLE #MermasRaw (
            fecha VARCHAR(50),
            producto VARCHAR(200),
            cantidad VARCHAR(50),
            sucursal VARCHAR(200)
        );

        -- ==========================================
        -- BULK INSERT DINÁMICO
        -- ==========================================

        DECLARE @sql NVARCHAR(MAX);

        SET @sql = '
        BULK INSERT #MermasRaw
        FROM ''' + @rutaArchivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''\n'',
            CODEPAGE = ''65001'',
            TABLOCK
        );';

        EXEC(@sql);

        SELECT @registros_staging = COUNT(*) FROM #MermasRaw;

        -- ==========================================
        -- UPSERT CATEGORÍA
        -- ==========================================

        IF NOT EXISTS (
            SELECT 1 FROM productos.Categoria WHERE nombre = 'General'
        )
        BEGIN
            INSERT INTO productos.Categoria (nombre, margen_ganancia)
            VALUES ('General', 30);
        END

        SELECT @id_categoria = id_categoria
        FROM productos.Categoria
        WHERE nombre = 'General';

        -- ==========================================
        -- UPSERT PRODUCTOS
        -- ==========================================

        INSERT INTO productos.Producto
        (nombre, descripcion, forma_comercializacion, tipo_producto_agricola, vida_util, id_categoria)
        SELECT DISTINCT
            m.producto,
            'Importado desde archivo de mermas',
            'unidad',
            'hoja verde',
            30,
            @id_categoria
        FROM #MermasRaw m
        WHERE NOT EXISTS (
            SELECT 1
            FROM productos.Producto p
            WHERE p.nombre = m.producto
        );

        -- ==========================================
        -- UPSERT SUCURSALES
        -- ==========================================

        INSERT INTO productos.Sucursal (nombre, direccion)
        SELECT DISTINCT
            m.sucursal,
            'Sucursal importada'
        FROM #MermasRaw m
        WHERE NOT EXISTS (
            SELECT 1
            FROM productos.Sucursal s
            WHERE s.nombre = m.sucursal
        );

        -- ==========================================
        -- VALIDACIONES (GUARDAR ERRORES)
        -- ==========================================

        INSERT INTO importaciones.ErroresMermas (descripcion, fila_producto, fila_sucursal)
        SELECT 'Fecha inválida', producto, sucursal
        FROM #MermasRaw
        WHERE TRY_CONVERT(DATE, fecha, 103) IS NULL;

        INSERT INTO importaciones.ErroresMermas (descripcion, fila_producto, fila_sucursal)
        SELECT 'Cantidad inválida', producto, sucursal
        FROM #MermasRaw
        WHERE TRY_CONVERT(INT, cantidad) IS NULL;

        SELECT @registros_error = @@ROWCOUNT;

        -- ==========================================
        -- INSERTAR REGISTROS VÁLIDOS
        -- ==========================================

        INSERT INTO importaciones.Merma (id_producto, id_sucursal, fecha, cantidad)
        SELECT 
            p.id_producto,
            s.id_sucursal,
            TRY_CONVERT(DATE, m.fecha, 103),
            TRY_CONVERT(INT, m.cantidad)
        FROM #MermasRaw m
        JOIN productos.Producto p ON p.nombre = m.producto
        JOIN productos.Sucursal s ON s.nombre = m.sucursal
        WHERE 
            TRY_CONVERT(DATE, m.fecha, 103) IS NOT NULL
            AND TRY_CONVERT(INT, m.cantidad) IS NOT NULL
            AND NOT EXISTS (
                SELECT 1 
                FROM importaciones.Merma me
                WHERE me.id_producto = p.id_producto
                AND me.id_sucursal = s.id_sucursal
                AND me.fecha = TRY_CONVERT(DATE, m.fecha, 103)
            );

        SET @registros_insertados = @@ROWCOUNT;

        -- ==========================================
        -- LOG DE IMPORTACIÓN (PERMANENTE)
        -- ==========================================

        INSERT INTO importaciones.LogImportacionMermas
        (registros_staging, registros_insertados, registros_error)
        VALUES (@registros_staging, @registros_insertados, @registros_error);

        -- ==========================================
        -- RESULTADO
        -- ==========================================

        SELECT 
            @registros_staging AS registros_recibidos,
            @registros_insertados AS registros_insertados,
            @registros_error AS registros_error;

    END TRY
    BEGIN CATCH
        INSERT INTO importaciones.ErroresMermas (descripcion)
        VALUES (ERROR_MESSAGE());
    END CATCH

END
GO