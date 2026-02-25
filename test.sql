
/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas - Comisión 2343 Verano
	Componentes del grupo:
		-Leonel Cespedes
		-Luciana Franchetti


    Descripción: Script de pruebas
*/

USE Com2343;

DECLARE @sql VARCHAR(MAX) = '';
=======
DECLARE @sql NVARCHAR(MAX) = '';

-- 1️⃣ Eliminar todas las foreign keys
SELECT @sql += 
    'ALTER TABLE [' + s.name + '].[' + t.name + '] DROP CONSTRAINT [' + fk.name + '];' + CHAR(13)
FROM sys.foreign_keys fk
JOIN sys.tables t ON fk.parent_object_id = t.object_id
JOIN sys.schemas s ON t.schema_id = s.schema_id;

EXEC sp_executesql @sql;



--RECREAR LA BASE:
USE master;
GO

IF EXISTS (SELECT 1 FROM sys.databases WHERE name = 'Com2343')
BEGIN
    ALTER DATABASE Com2343 SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE Com2343;
END
GO

CREATE DATABASE Com2343;
GO


