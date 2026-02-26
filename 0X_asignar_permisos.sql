/*
 Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
    Componentes del grupo:
        - Leonel Cespedes
        - Luciana Franchetti

Configuración de Seguridad (Entrega 7) - Roles y Usuarios
*/


USE Com2343;
GO

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'csps')
BEGIN
    EXEC('CREATE SCHEMA csps')
END 
GO

-- 1. Permiso para actualización de Stock y Productos (Reemplaza Datos UF)
-- El Vendedor necesita modificar stock ante mermas o ventas[cite: 109].
CREATE OR ALTER PROCEDURE csps.sp_PermisosGestionStock_00
    @NombreRol VARCHAR(30)
AS
BEGIN   
    SET NOCOUNT ON;
    DECLARE @SQLQuery NVARCHAR(MAX);

    -- Permiso para actualizar tablas de inventario
    SET @SQLQuery = N'GRANT UPDATE, SELECT ON ct.Productos TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;

    SET @SQLQuery = N'GRANT UPDATE, SELECT ON ct.StockLotes TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;
END
GO

-- 2. Permiso para Importación de Listas de Precios y Capacitadores (Reemplaza Inf. Bancaria)
-- El Proveedor o el Importador deben cargar archivos externos[cite: 59, 114].
CREATE OR ALTER PROCEDURE csps.sp_PermisosImportacionExterna_01
    @NombreRol VARCHAR(30)
AS
BEGIN   
    SET NOCOUNT ON;
    DECLARE @SQLQuery NVARCHAR(MAX);

    -- Permiso para insertar en tablas de precios mayoristas y capacitadores
    SET @SQLQuery = N'GRANT INSERT, UPDATE ON ct.PrecioMayorista TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;

    SET @SQLQuery = N'GRANT INSERT, UPDATE ON ct.Capacitadores TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;
END
GO

-- 3. Permiso para Generación de Reportes de Negocio (Reemplaza Flujo de Caja)
-- Acceso a los reportes específicos requeridos en la Entrega 6[cite: 124, 125].
CREATE OR ALTER PROCEDURE csps.sp_PermisosReportesNegocio_02
    @NombreRol VARCHAR(30)
AS
BEGIN   
    SET NOCOUNT ON;
    DECLARE @SQLQuery NVARCHAR(MAX);

    -- Reporte 1: Rentabilidad (Costo vs Venta) [cite: 126]
    SET @SQLQuery = N'GRANT EXECUTE ON cspr.sp_ReporteRentabilidad_01 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;

    -- Reporte 2: Alerta de Vencimientos (Próximos 3 días) [cite: 127]
    SET @SQLQuery = N'GRANT EXECUTE ON cspr.sp_AlertaVencimientos_02 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;

    -- Reporte 4: Matriz de Desperdicio (Pivot de Kilos) [cite: 129]
    SET @SQLQuery = N'GRANT EXECUTE ON cspr.sp_MatrizDesperdicio_04 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;

    -- Reporte 6: Recomendaciones por API Externa (Clima/Dólar) [cite: 131]
    SET @SQLQuery = N'GRANT EXECUTE ON cspr.sp_RecomendacionesAPI_06 TO [' + @NombreRol + N'];';
    EXEC sp_executesql @SQLQuery;
END
GO