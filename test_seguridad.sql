/*
 =========================================================
   DEMOSTRACIÓN DEL CIFRADO DE DATOS SENSIBLES
 =========================================================

Objetivo:
Demostrar que los datos sensibles (telefono y cuit)
ya no se almacenan en texto plano sino cifrados
mediante AES_256.

La prueba consta de 3 pasos:

1) Insertar proveedor de prueba
2) Ver almacenamiento físico (VARBINARY)
3) Ver descifrado mediante SP seguro
 =========================================================
*/

USE Com2343;
GO


/* =====================================================
1) INSERTAR PROVEEDOR DE PRUEBA
===================================================== */

EXEC csp.AltaProveedor
    @nombre = 'ProveedorDemo',
    @apellido = 'Seguridad',
    @telefono = '12345678',
    @cuit = '20-12345678-9';
GO


/* =====================================================
2) VER DATOS ALMACENADOS FÍSICAMENTE (CIFRADOS)
=====================================================

Se consulta directamente la tabla productiva.
Los campos telefono_cifrado y cuit_cifrado
deben verse en formato hexadecimal (0x...).
*/

SELECT 
    id_proveedor,
    nombre,
    apellido,
    telefono_cifrado,
    cuit_cifrado
FROM proveedores.Proveedor
WHERE nombre = 'ProveedorDemo';
GO


/*
Resultado esperado:

telefono_cifrado = 0x00A1B45C...
cuit_cifrado     = 0x0098DF23...

Esto demuestra que:
- Los datos no se almacenan en texto plano.
- Se encuentran cifrados físicamente en la base.
*/


/* =====================================================
3) CONSULTA DESCIFRADA MEDIANTE SP SEGURO
=====================================================

Se utiliza el procedimiento almacenado que:
- Abre la clave simétrica
- Descifra los datos
- Cierra la clave
*/

EXEC csp.ConsultarProveedorSeguro;
GO


/*
Resultado esperado:

telefono = 12345678
cuit     = 20-12345678-9

Esto demuestra que:

*  El cifrado funciona correctamente.
*  Los datos solo pueden leerse mediante apertura de clave.
*  El acceso está controlado por procedimiento almacenado.
*  Se cumple el principio de confidencialidad.
*/