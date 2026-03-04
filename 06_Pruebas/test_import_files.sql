/*
=========================================================
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas
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
=========================================================
*/


-- ==============================
-- TEST – PROCESAR MERMAS
-- ==============================
USE Com2343;
GO

PRINT '=== INICIO TEST MERMAS ===';

-- 1️) Ejecutar proceso
EXEC csp.ProcesarMermas
    @rutaArchivo = 'C:\Importaciones\mermas.csv';
GO

-- 2️) Ver datos insertados en tabla productiva
SELECT *
FROM importaciones.Merma
ORDER BY fecha DESC;
GO

-- 3️) Ver errores detectados
SELECT *
FROM importaciones.ErroresMermas
ORDER BY fecha DESC;
GO

-- 4️) Ver log de importación
SELECT *
FROM importaciones.LogImportacionMermas
ORDER BY fecha_importacion DESC;
GO

PRINT '=== FIN TEST MERMAS ===';

-- ==============================
-- TEST – PROCESAR ESTIMACIONES
-- ==============================

USE Com2343;
GO

PRINT '=== INICIO TEST ESTIMACIONES ===';

-- 1️) Ejecutar proceso
EXEC csp.ProcesarEstimaciones
    @rutaArchivo = 'C:\Importaciones\estimaciones.csv';
GO

-- 2️) Ver total en tabla final
SELECT COUNT(*) AS TotalFinal
FROM importaciones.EstimacionAgricola;
GO

-- 3️) Ver últimos registros insertados/actualizados
SELECT TOP 20 *
FROM importaciones.EstimacionAgricola
ORDER BY id_estimacion DESC;
GO

-- 4️) Ver errores detectados
SELECT *
FROM importaciones.ErroresEstimaciones
ORDER BY fecha DESC;
GO

-- 5️) Ver log de importación
SELECT *
FROM importaciones.LogImportacionEstimaciones
ORDER BY id_log DESC;
GO

PRINT '=== FIN TEST ESTIMACIONES ===';



-- =========================================
-- TEST – PROCESAR CAPACITADORES
-- =========================================

USE Com2343;
GO

PRINT '=== INICIO TEST CAPACITADORES ===';

-- 1️) Ejecutar proceso
EXEC csp.ProcesarCapacitadores
    @rutaArchivo = 'C:\Importaciones\capacitadores.csv';
GO

-- 2️) Verificar tabla final
SELECT COUNT(*) AS TotalCapacitadores
FROM ventas.Capacitador;
GO

SELECT TOP 20 *
FROM ventas.Capacitador
ORDER BY id_capacitador DESC;
GO

-- 3) Ver errores detectados
SELECT *
FROM importaciones.ErroresCapacitadores
ORDER BY fecha DESC;
GO

-- 4) Ver log de importaciones
SELECT *
FROM importaciones.LogImportacionCapacitadores
ORDER BY id_log DESC;
GO

PRINT '=== FIN TEST CAPACITADORES ===';




-- =========================================
-- TEST – PROCESAR PRECIOS
-- FRUTAS Y HORTALIZAS
-- =========================================

USE Com2343;
GO

PRINT '=== INICIO TEST PRECIOS ===';

-- =========================================
-- 1)Ejecutar procesamiento
-- =========================================

-- FRUTAS
EXEC csp.ProcesarPrecios
    @rutaArchivo = 'C:\importaciones\FRUTAS_FEBRERO-26_0\RF250226.csv',
    @fecha = '2026-02-23',
    @tipo_producto = 'fruta';
GO

-- HORTALIZAS
EXEC csp.ProcesarPrecios
    @rutaArchivo = 'C:\importaciones\HORTALIZAS_FEBRERO-26\RH250226.csv',
    @fecha = '2026-02-02',
    @tipo_producto = 'hortaliza';
GO


-- =========================================
-- 2) Verificar tabla final
-- =========================================

SELECT COUNT(*) AS TotalRegistros
FROM importaciones.PrecioMayorista;
GO

SELECT TOP 20 *
FROM importaciones.PrecioMayorista
ORDER BY id_precio DESC;
GO


-- =========================================
-- 3) Ver errores detectados
-- =========================================

SELECT *
FROM importaciones.ErroresPrecios
ORDER BY fecha DESC;
GO


-- =========================================
-- 4) Ver log de importaciones
-- =========================================

SELECT *
FROM importaciones.LogImportacionPrecios
ORDER BY id_log DESC;
GO

PRINT '=== FIN TEST PRECIOS ===';