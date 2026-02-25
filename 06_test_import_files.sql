/*
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas - Comisión 2343 Verano
Grupo:
- Leonel Cespedes
- Luciana Franchetti

Entrega 5 – Procesos de Importación
Archivo procesado: Estimaciones

Arquitectura implementada:

1) STAGING (zona sucia)
2) PROCESAMIENTO
3) TABLAS FINALES

Flujo:
Archivo CSV → staging → SP procesamiento → ct.Merma
*/


-- ==============================
-- MERMAs
-- ==============================
USE Com2343;
GO

EXEC csp.ProcesarMermas;
GO


SELECT *
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'staging'
AND TABLE_NAME = 'LogImportacionMermas';


-- Ver registros insertados
SELECT * FROM staging.MermasRaw;

-- Ver registros insertados
SELECT * FROM ct.Merma;

-- Ver errores detectados
SELECT * FROM staging.ErroresMermas;

-- Ver log de importaciones
SELECT * FROM staging.LogImportacionMermas;


-- ==============================
-- ESTIMACIONES
--1)Primero: limpiar staging y errores (hecho en 05_2_import_files_estimaciones.sql )
--2)Cargar el archivo (hecho en 05_2_import_files_estimaciones.sql )
--3)Verificar que realmente cargó staging
--4)Ejecutar el procesamiento
--5)Verificar tabla final
--6)Ver errores y log 
-- ==============================

--3)
SELECT COUNT(*) AS RegistrosEnStaging
FROM staging.EstimacionesRaw;

SELECT TOP 10 *
FROM staging.EstimacionesRaw;

--4)
EXEC csp.ProcesarEstimaciones;
GO

--5)
SELECT COUNT(*) AS TotalFinal
FROM ct.EstimacionAgricola;

SELECT TOP 20 *
FROM ct.EstimacionAgricola
ORDER BY id_estimacion DESC;

--6) y 7)
SELECT *
FROM staging.ErroresEstimaciones;

SELECT *
FROM staging.LogImportacionEstimaciones
ORDER BY id_log DESC;



-- ==============================
-- CAPACITADORES
--1)Primero: limpiar staging y errores (hecho en 05_3_import_files_capacitadores.sql )
--2)Cargar el archivo (hecho en 05_3_import_files_capacitadores.sql )
--3)Verificar que realmente cargó staging
--4)Ejecutar el procesamiento
--5)Verificar tabla final
--6)Ver errores y log 
-- ==============================

-- 3) Verificar que staging cargó bien

SELECT COUNT(*) AS RegistrosEnStaging
FROM staging.CapacitadoresRaw;

SELECT TOP 10 *
FROM staging.CapacitadoresRaw;


-- 4) Ejecutar procesamiento

EXEC csp.ProcesarCapacitadores;
GO

-- 5) Verificar tabla final
SELECT COUNT(*) AS TotalCapacitadores
FROM ct.Capacitador;

SELECT TOP 20 *
FROM ct.Capacitador
ORDER BY id_capacitador DESC;


-- 6) Ver errores detectados

SELECT * FROM staging.ErroresCapacitadores;


-- 7) Ver log de importaciones

SELECT * FROM staging.LogImportacionCapacitadores
ORDER BY id_log DESC;


-- ==============================
-- FRUTAS Y HORTALIZAS

-- ==============================

--ejecucion de sp para las frutas
EXEC csp.ProcesarPrecios 
    @fecha = '2026-02-02',
    @tipo_producto = 'fruta';
GO

--ejecucion de sp para las hortalizas
EXEC csp.ProcesarPrecios 
    @fecha = '2026-02-02',
    @tipo_producto = 'hortaliza';
GO


-- Ver staging
SELECT COUNT(*) FROM staging.PreciosRaw;

-- Ver tabla final
SELECT TOP 20 *
FROM ct.PrecioMayorista
ORDER BY id_precio DESC;

-- Ver errores
SELECT *
FROM staging.ErroresPrecios;

-- Ver log
SELECT *
FROM staging.LogImportacionPrecios
ORDER BY id_log DESC;