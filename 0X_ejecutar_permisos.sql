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

-- 1. Permisos para Vendedor
-- Requiere gestionar stock y visualizar reportes de vencimientos (FEFO)[cite: 56, 127].
EXEC csps.sp_PermisosGestionStock_00 'Rol_Vendedor';
EXEC csps.sp_PermisosReportesNegocio_02 'Rol_Vendedor';
GO

-- 2. Permisos para Proveedor
-- Requiere importar sus listas de precios de referencia (CSV/JSON)[cite: 59, 114].
EXEC csps.sp_PermisosImportacionExterna_01 'Rol_Proveedor';
GO

-- 3. Permisos para Capacitador
-- Debe mantener actualizado el padrón de capacitadores de manipuladores de alimentos[cite: 112].
EXEC csps.sp_PermisosImportacionExterna_01 'Rol_Capacitador';
GO

-- 4. Permisos para Cliente
-- Acceso a reportes de disponibilidad de productos y recomendaciones[cite: 131].
EXEC csps.sp_PermisosReportesNegocio_02 'Rol_Cliente';
GO

-- ============== VERIFICACIÓN DE PERMISOS OTORGADOS =======================

SELECT
    perms.state_desc AS [Estado],
    perms.permission_name AS [Permiso],
    obj.name AS [Objeto / SP],
    dp.name AS [Rol Asignado]
FROM sys.database_permissions AS perms
JOIN sys.database_principals AS dp
    ON perms.grantee_principal_id = dp.principal_id
JOIN sys.objects AS obj
    ON perms.major_id = obj.object_id
WHERE dp.name IN ('Rol_Vendedor', 'Rol_Capacitador', 'Rol_Proveedor', 'Rol_Cliente')
ORDER BY dp.name, perms.permission_name;
GO