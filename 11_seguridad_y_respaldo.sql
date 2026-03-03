/*
=========================================================
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas

Grupo:
- Leonel Cespedes
- Luciana Franchetti

Entrega 7 – Seguridad y Respaldo

Descripción General:
En esta entrega se implementan:

1) Cifrado de datos sensibles utilizando:
   - Master Key
   - Certificado
   - Clave Simétrica (AES_256)
   - Migración segura de columnas existentes
   - Modificación de Store Procedures

2) Creación de Roles de seguridad con permisos granulares.

3) Definición de Política de Backup (RPO documentado).

=========================================================
*/

USE Com2343;
GO

/* =========================================================
   =====================  CIFRADO  =========================
   ========================================================= */

/*
Objetivo:
Proteger datos sensibles de proveedores:
- telefono
- cuit

Se implementa cifrado simétrico AES_256
y se realiza migración segura de datos existentes.
 =========================================================
   DEMOSTRACIÓN DEL CIFRADO
 =========================================================

ANTES del cifrado:
Los datos sensibles se almacenaban en texto plano:

telefono = '12345678'
cuit     = '20-12345678-9'

DESPUÉS del cifrado:
Los datos se almacenan como VARBINARY en formato hexadecimal.
*/

-- Ver datos almacenados físicamente (cifrados)
SELECT id_proveedor, nombre, apellido, telefono, cuit
FROM ct.Proveedor;
GO

/*
Se observa que telefono y cuit ahora aparecen como:

0x002D65EB2CF74C458A374C1460F2DF1202000000...

Lo que indica que están correctamente cifrados.
*/

-- Ver datos descifrados mediante SP seguro
EXEC csp.ConsultarProveedorSeguro;
GO

/*
Aquí se observa nuevamente:

telefono = 12345678
cuit     = 20-12345678-9

Esto demuestra que:
- Los datos están protegidos físicamente
- Solo pueden leerse mediante clave simétrica
- El acceso está controlado por SP
*/

*/

------------------------------------------------------------
-- 1) Crear Master Key (si no existe)
------------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.symmetric_keys 
    WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY
    ENCRYPTION BY PASSWORD = 'ClaveSuperSegura123!';
END
GO

------------------------------------------------------------
-- 2) Crear Certificado
------------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.certificates 
    WHERE name = 'CertificadoSeguridad'
)
BEGIN
    CREATE CERTIFICATE CertificadoSeguridad
    WITH SUBJECT = 'Certificado para cifrado de datos sensibles';
END
GO

------------------------------------------------------------
-- 3) Crear Clave Simétrica AES_256
------------------------------------------------------------
IF NOT EXISTS (
    SELECT * FROM sys.symmetric_keys 
    WHERE name = 'ClaveProveedores'
)
BEGIN
    CREATE SYMMETRIC KEY ClaveProveedores
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CertificadoSeguridad;
END
GO

------------------------------------------------------------
-- 4) Migración segura de columnas sensibles
------------------------------------------------------------
/*
No se usa ALTER COLUMN directo porque:
- Existen datos previos
- Existe un CHECK constraint sobre cuit
*/

-- 4.1 Agregar nuevas columnas cifradas si no existen
IF COL_LENGTH('ct.Proveedor','telefono_cifrado') IS NULL
BEGIN
    ALTER TABLE ct.Proveedor
    ADD telefono_cifrado VARBINARY(256);
END
GO

IF COL_LENGTH('ct.Proveedor','cuit_cifrado') IS NULL
BEGIN
    ALTER TABLE ct.Proveedor
    ADD cuit_cifrado VARBINARY(256);
END
GO

-- 4.2 Migrar datos existentes
OPEN SYMMETRIC KEY ClaveProveedores
DECRYPTION BY CERTIFICATE CertificadoSeguridad;

UPDATE ct.Proveedor
SET telefono_cifrado = EncryptByKey(Key_GUID('ClaveProveedores'), telefono),
    cuit_cifrado = EncryptByKey(Key_GUID('ClaveProveedores'), cuit)
WHERE telefono IS NOT NULL OR cuit IS NOT NULL;

CLOSE SYMMETRIC KEY ClaveProveedores;
GO

-- 4.3 Eliminar CHECK constraint del CUIT si existe
IF EXISTS (
    SELECT * FROM sys.check_constraints 
    WHERE name = 'ck_cuit'
)
BEGIN
    ALTER TABLE ct.Proveedor DROP CONSTRAINT ck_cuit;
END
GO

-- 4.4 Eliminar columnas originales si existen
IF COL_LENGTH('ct.Proveedor','telefono') IS NOT NULL
BEGIN
    ALTER TABLE ct.Proveedor DROP COLUMN telefono;
END
GO

IF COL_LENGTH('ct.Proveedor','cuit') IS NOT NULL
BEGIN
    ALTER TABLE ct.Proveedor DROP COLUMN cuit;
END
GO

-- 4.5 Renombrar columnas cifradas
IF COL_LENGTH('ct.Proveedor','telefono_cifrado') IS NOT NULL
BEGIN
    EXEC sp_rename 
        'ct.Proveedor.telefono_cifrado', 
        'telefono', 
        'COLUMN';
END
GO

IF COL_LENGTH('ct.Proveedor','cuit_cifrado') IS NOT NULL
BEGIN
    EXEC sp_rename 
        'ct.Proveedor.cuit_cifrado', 
        'cuit', 
        'COLUMN';
END
GO

------------------------------------------------------------
-- 5) Modificación del SP AltaProveedor
------------------------------------------------------------
CREATE OR ALTER PROCEDURE csp.AltaProveedor
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @telefono VARCHAR(20),
    @cuit VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY ClaveProveedores
    DECRYPTION BY CERTIFICATE CertificadoSeguridad;

    INSERT INTO ct.Proveedor(nombre, apellido, telefono, cuit)
    VALUES(
        @nombre,
        @apellido,
        EncryptByKey(Key_GUID('ClaveProveedores'), @telefono),
        EncryptByKey(Key_GUID('ClaveProveedores'), @cuit)
    );

    CLOSE SYMMETRIC KEY ClaveProveedores;
END
GO

------------------------------------------------------------
-- 6) SP para consulta descifrada
------------------------------------------------------------
CREATE OR ALTER PROCEDURE csp.ConsultarProveedorSeguro
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY ClaveProveedores
    DECRYPTION BY CERTIFICATE CertificadoSeguridad;

    SELECT
        nombre,
        apellido,
        CONVERT(VARCHAR(20), DecryptByKey(telefono)) AS telefono,
        CONVERT(VARCHAR(100), DecryptByKey(cuit)) AS cuit
    FROM ct.Proveedor;

    CLOSE SYMMETRIC KEY ClaveProveedores;
END
GO

--SALIDA
SELECT * FROM ct.Proveedor;
EXEC csp.ConsultarProveedorSeguro;

/* =========================================================
   =======================  ROLES  =========================
   ========================================================= */

/*
Aplicación del principio de menor privilegio.
*/

-- Crear roles si no existen
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'admin')
    CREATE ROLE admin;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'importador')
    CREATE ROLE importador;

IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = 'consultas')
    CREATE ROLE consultas;
GO

-- ADMIN
ALTER ROLE db_owner ADD MEMBER admin;

-- IMPORTADOR
GRANT INSERT ON SCHEMA::staging TO importador;
GRANT EXECUTE ON SCHEMA::csp TO importador;

-- CONSULTAS
GRANT SELECT ON SCHEMA::ct TO consultas;
GRANT EXECUTE ON OBJECT::csp.ReporteRentabilidadXML TO consultas;
GRANT EXECUTE ON OBJECT::csp.MatrizDesperdicio TO consultas;
--GRANT EXECUTE ON OBJECT::csp.RecomendacionClimaXML TO consultas;
GO

--SALIDA
SELECT name FROM sys.database_principals
WHERE type = 'R';

/* =========================================================
   =======================  BACKUP  ========================
   ========================================================= */

/*
POLÍTICA DE RESPALDO (RPO)

RPO definido: 24 horas máximo de pérdida de datos.

Estrategia:

1) Backup Completo:
   - Diario a las 23:59
   - Retención 30 días

2) Backup Diferencial:
   - Cada 4 horas

3) Backup de Log:
   - Cada 1 hora

4) Copias almacenadas:
   - Servidor local
   - Servidor secundario externo

Justificación:
Los precios cambian diariamente, por lo tanto
una pérdida máxima de 24 horas es aceptable
según criticidad del sistema.
*/


