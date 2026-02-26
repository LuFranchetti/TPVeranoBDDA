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

-- ==============  ELIMINAR LOGINS (Si existen)  =======================
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Login_Vendedor') DROP LOGIN [Login_Vendedor];
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Login_Capacitador') DROP LOGIN [Login_Capacitador];
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Login_Proveedor') DROP LOGIN [Login_Proveedor];
IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = 'Login_Cliente') DROP LOGIN [Login_Cliente];
GO

-- ==============  ELIMINAR USUARIOS (Si existen)  =======================
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'User_Vendedor') DROP USER [User_Vendedor];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'User_Capacitador') DROP USER [User_Capacitador];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'User_Proveedor') DROP USER [User_Proveedor];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'User_Cliente') DROP USER [User_Cliente];
GO

-- ==============  ELIMINAR ROLES (Si existen)  =======================
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Vendedor') DROP ROLE [Rol_Vendedor];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Capacitador') DROP ROLE [Rol_Capacitador];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Proveedor') DROP ROLE [Rol_Proveedor];
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = 'Rol_Cliente') DROP ROLE [Rol_Cliente];
GO

-- ==============  CREACION DE LOGINS  =======================
-- Nota: En un entorno real, use contraseñas seguras y cámbielas.
CREATE LOGIN Login_Vendedor WITH PASSWORD = 'PasswordVendedor2026', CHECK_POLICY = ON;
CREATE LOGIN Login_Capacitador WITH PASSWORD = 'PasswordCapacitador2026', CHECK_POLICY = ON;
CREATE LOGIN Login_Proveedor WITH PASSWORD = 'PasswordProveedor2026', CHECK_POLICY = ON;
CREATE LOGIN Login_Cliente WITH PASSWORD = 'PasswordCliente2026', CHECK_POLICY = ON;
GO 

-- ==============  CREACION DE USUARIOS DE BASE DE DATOS  =======================
CREATE USER User_Vendedor FOR LOGIN Login_Vendedor WITH DEFAULT_SCHEMA = [ct];
CREATE USER User_Capacitador FOR LOGIN Login_Capacitador WITH DEFAULT_SCHEMA = [ct];
CREATE USER User_Proveedor FOR LOGIN Login_Proveedor WITH DEFAULT_SCHEMA = [ct];
CREATE USER User_Cliente FOR LOGIN Login_Cliente WITH DEFAULT_SCHEMA = [ct];
GO

-- ==============  CREACION DE ROLES  =======================
CREATE ROLE Rol_Vendedor;     -- Gestión de ventas y stock local [cite: 61, 65]
CREATE ROLE Rol_Capacitador;  -- Registro de certificados de manipulación 
CREATE ROLE Rol_Proveedor;    -- Consulta de listas de precios y pedidos [cite: 51, 59]
CREATE ROLE Rol_Cliente;      -- Consulta de productos y seguimiento de pedidos 
GO

-- ==============  ASIGNACION DE MIEMBROS  =======================
ALTER ROLE Rol_Vendedor ADD MEMBER User_Vendedor;
ALTER ROLE Rol_Capacitador ADD MEMBER User_Capacitador;
ALTER ROLE Rol_Proveedor ADD MEMBER User_Proveedor;
ALTER ROLE Rol_Cliente ADD MEMBER User_Cliente;
GO

-- ==============  VERIFICACION  =======================
SELECT 
    Rol.name AS Nombre_del_Rol, 
    Miembro.name AS Usuario_Miembro
FROM sys.database_role_members AS drm
INNER JOIN sys.database_principals AS Rol ON drm.role_principal_id = Rol.principal_id
INNER JOIN sys.database_principals AS Miembro ON drm.member_principal_id = Miembro.principal_id
WHERE Rol.name IN ('Rol_Vendedor', 'Rol_Capacitador', 'Rol_Proveedor', 'Rol_Cliente')
ORDER BY Nombre_del_Rol;
GO