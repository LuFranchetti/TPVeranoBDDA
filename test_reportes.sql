/*
    Universidad Nacional de La Matanza
    Materia: Base de Datos Aplicadas
	Componentes del grupo:
		-Leonel Cespedes
		-Luciana Franchetti


    Descripción: Script de pruebas de generacion de los reportes.
*/



/*
=========================================================
-- Probar el Reporte de Rentabilidad (XML)
=========================================================
*/
USE Com2343

-- Ejecución del reporte
/*
Ese XML está diciendo:
La categoría Frutas vendió 16.000
Costó 10.000
Ganó 6.000
Tiene un margen del 37,5%
*/
EXEC csp.ReporteRentabilidadXML;



/*
=========================================================
-- Probar el Reporte de Alerta de vencimientos.
=========================================================
*/
--Caso 1 – próximos 15 días (traer mi lote)
EXEC csp.AlertaVencimientosXML @dias = 15;





/*
=========================================================
-- Probar el Reporte de Ranking de Proveedores
=========================================================
*/
EXEC csp.RankingProveedores;


/*
=========================================================
-- Probar el Reporte de Matriz de desperdicios
=========================================================
*/

EXEC csp.MatrizDesperdicio;

/*
=========================================================
-- Probar el Reporte de Informe de faltantes
=========================================================
*/

EXEC csp.InformeFaltantes;