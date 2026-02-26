
/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
	Componentes del grupo:
		-Leonel Cespedes
		-Luciana Franchetti


    Descripción: Creación de la base Com2343
*/

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

ALTER DATABASE Com2343 SET MULTI_USER;
GO

USE Com2343;
GO