/*
=========================================================
UNLaM – Base de Datos Aplicadas
Entrega 7 – Seguridad y Respaldo

Grupo:
- Leonel Cespedes
- Luciana Franchetti

Descripción:
Este script implementa:

1) Cifrado de datos sensibles (telefono y cuit de proveedores)
   utilizando Master Key + Certificado + Clave Simétrica AES_256.

2) Modificación de Store Procedures para insertar y consultar
   datos cifrados.

3) Creación de roles con permisos granulares siguiendo el
   principio de menor privilegio.
=========================================================
*/

USE Com2343;
GO

/* =====================================================
====================== CIFRADO ==========================
===================================================== */

/*
1) MASTER KEY
Se crea la clave maestra de la base de datos.
Es la raíz de la jerarquía de cifrado.
Protege certificados y claves simétricas.
*/

IF NOT EXISTS (
    SELECT * FROM sys.symmetric_keys 
    WHERE name = '##MS_DatabaseMasterKey##'
)
BEGIN
    CREATE MASTER KEY
    ENCRYPTION BY PASSWORD = 'ClaveSeguraTP2026!';
END
GO


/*
2) CERTIFICADO
Se crea un certificado que protegerá la clave simétrica.
Actúa como mecanismo intermedio de seguridad.
*/

IF NOT EXISTS (
    SELECT * FROM sys.certificates 
    WHERE name = 'CertificadoProveedores'
)
BEGIN
    CREATE CERTIFICATE CertificadoProveedores
    WITH SUBJECT = 'Cifrado de datos sensibles - Proveedores';
END
GO


/*
3) CLAVE SIMÉTRICA AES_256
Se crea una clave simétrica usando algoritmo AES_256.
Esta clave será utilizada para cifrar y descifrar datos.
*/

IF NOT EXISTS (
    SELECT * FROM sys.symmetric_keys 
    WHERE name = 'ClaveSimetricaProveedores'
)
BEGIN
    CREATE SYMMETRIC KEY ClaveSimetricaProveedores
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE CertificadoProveedores;
END
GO


/*
4) AGREGAR COLUMNAS CIFRADAS
Se agregan columnas VARBINARY para almacenar
los datos cifrados sin eliminar las originales.
*/

IF COL_LENGTH('proveedores.Proveedor','telefono_cifrado') IS NULL
BEGIN
    ALTER TABLE proveedores.Proveedor
    ADD telefono_cifrado VARBINARY(256);
END
GO

IF COL_LENGTH('proveedores.Proveedor','cuit_cifrado') IS NULL
BEGIN
    ALTER TABLE proveedores.Proveedor
    ADD cuit_cifrado VARBINARY(256);
END
GO


/*
5) MIGRACIÓN DE DATOS EXISTENTES
Se cifran los valores actuales y se guardan
en las nuevas columnas.
*/

OPEN SYMMETRIC KEY ClaveSimetricaProveedores
DECRYPTION BY CERTIFICATE CertificadoProveedores;

UPDATE proveedores.Proveedor
SET telefono_cifrado = EncryptByKey(Key_GUID('ClaveSimetricaProveedores'), telefono),
    cuit_cifrado = EncryptByKey(Key_GUID('ClaveSimetricaProveedores'), cuit)
WHERE telefono IS NOT NULL;

CLOSE SYMMETRIC KEY ClaveSimetricaProveedores;
GO


/* =====================================================
======= MODIFICACIÓN DE STORE PROCEDURES ===============
===================================================== */

/*
6) SP AltaProveedor
Se modifica para que inserte directamente los datos
ya cifrados en la base de datos.
*/

CREATE OR ALTER PROCEDURE csp.AltaProveedor
    @nombre VARCHAR(100),
    @apellido VARCHAR(100),
    @telefono VARCHAR(20),
    @cuit VARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY ClaveSimetricaProveedores
    DECRYPTION BY CERTIFICATE CertificadoProveedores;

    INSERT INTO proveedores.Proveedor
    (nombre, apellido, telefono_cifrado, cuit_cifrado)
    VALUES
    (
        @nombre,
        @apellido,
        EncryptByKey(Key_GUID('ClaveSimetricaProveedores'), @telefono),
        EncryptByKey(Key_GUID('ClaveSimetricaProveedores'), @cuit)
    );

    CLOSE SYMMETRIC KEY ClaveSimetricaProveedores;
END
GO


/*
7) SP ConsultarProveedorSeguro
Permite visualizar los datos descifrados.
Se abre la clave simétrica, se descifran los datos
y luego se cierra la clave.
*/

CREATE OR ALTER PROCEDURE csp.ConsultarProveedorSeguro
AS
BEGIN
    SET NOCOUNT ON;

    OPEN SYMMETRIC KEY ClaveSimetricaProveedores
    DECRYPTION BY CERTIFICATE CertificadoProveedores;

    SELECT
        nombre,
        apellido,
        CONVERT(VARCHAR(20), DecryptByKey(telefono_cifrado)) AS telefono,
        CONVERT(VARCHAR(100), DecryptByKey(cuit_cifrado)) AS cuit
    FROM proveedores.Proveedor;

    CLOSE SYMMETRIC KEY ClaveSimetricaProveedores;
END
GO



/* =====================================================
======================= ROLES ===========================
===================================================== */

/*
Se crean roles siguiendo el principio de menor privilegio.
Cada rol tiene permisos específicos según su función.
*/

-- Crear roles
CREATE ROLE rol_admin;
CREATE ROLE rol_importador;
CREATE ROLE rol_consulta;
GO


/*
ROL ADMIN
Tiene control total sobre la base.
Equivale a administrador funcional del sistema.
*/

GRANT CONTROL ON DATABASE::Com2343 TO rol_admin;


 /*
ROL IMPORTADOR
Puede insertar datos en el esquema importaciones
y ejecutar procedimientos de carga.
*/

GRANT INSERT ON SCHEMA::importaciones TO rol_importador;
GRANT EXECUTE ON SCHEMA::csp TO rol_importador;


 /*
ROL CONSULTA
Puede consultar información y ejecutar reportes,
pero no modificar datos.
*/

GRANT SELECT ON SCHEMA::productos TO rol_consulta;
GRANT SELECT ON SCHEMA::ventas TO rol_consulta;
GRANT SELECT ON SCHEMA::proveedores TO rol_consulta;

GRANT EXECUTE ON OBJECT::csp.MatrizDesperdicio TO rol_consulta;
GRANT EXECUTE ON OBJECT::csp.RankingProveedores TO rol_consulta;
GRANT EXECUTE ON OBJECT::csp.InformeFaltantes TO rol_consulta;
GO