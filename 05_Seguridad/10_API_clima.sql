/*
=========================================================
Universidad Nacional de La Matanza
Materia: Base de Datos Aplicadas

Grupo:
- Leonel Cespedes
- Luciana Franchetti

Entrega 6 – Reportes y API Externa

SP: csp.RecomendacionClimaXML

Descripción:
Este Stored Procedure consume una API pública de clima
(Open-Meteo) utilizando OLE Automation desde SQL Server.

Objetivo:
- Obtener la temperatura máxima proyectada para Buenos Aires.
- Aplicar una regla de negocio:
    * Si la temperatura es mayor o igual a 30°C,
      recomendar aumentar stock de frutas de verano.
    * Caso contrario, mantener demanda normal.
- Retornar el resultado en formato XML.

Observación:
Se utiliza integración HTTP vía MSXML2.XMLHTTP
y procesamiento de JSON mediante OPENJSON.
=========================================================
*/

USE Com2343;
GO

CREATE OR ALTER PROCEDURE csp.RecomendacionClimaXML
AS
BEGIN
    SET NOCOUNT ON;

    ----------------------------------------------------------------
    -- 1)Definición de URL de la API
    ----------------------------------------------------------------
    -- API pública Open-Meteo
    -- Coordenadas: Buenos Aires
    -- Se solicita temperatura máxima diaria
    ----------------------------------------------------------------
    DECLARE @url NVARCHAR(500) =
    'https://api.open-meteo.com/v1/forecast?latitude=-34.61&longitude=-58.38&daily=temperature_2m_max&timezone=America%2FArgentina%2FBuenos_Aires';


    ----------------------------------------------------------------
    -- 2️)Declaración de variables para OLE y JSON
    ----------------------------------------------------------------
    DECLARE @Object INT;              -- Objeto HTTP
    DECLARE @respuesta NVARCHAR(MAX); -- Respuesta cruda JSON
    DECLARE @json TABLE(data NVARCHAR(MAX)); -- Tabla variable para almacenar JSON


    ----------------------------------------------------------------
    -- 3️) Creación del objeto HTTP y ejecución del GET
    ----------------------------------------------------------------
    -- Se crea instancia del objeto MSXML2.XMLHTTP
    -- Se abre conexión tipo GET
    -- Se envía la solicitud
    -- Se captura la respuesta en formato JSON
    ----------------------------------------------------------------
    EXEC sp_OACreate 'MSXML2.XMLHTTP', @Object OUT;
    EXEC sp_OAMethod @Object, 'OPEN', NULL, 'GET', @url, 'FALSE';
    EXEC sp_OAMethod @Object, 'SEND';
    EXEC sp_OAMethod @Object, 'RESPONSETEXT', @respuesta OUTPUT;

    ----------------------------------------------------------------
    -- 4️) Insertar respuesta en tabla variable
    ----------------------------------------------------------------
    INSERT INTO @json
        EXEC sp_OAGetProperty @Object, 'RESPONSETEXT';

    ----------------------------------------------------------------
    -- 5️) Extraer JSON para procesarlo
    ----------------------------------------------------------------
    DECLARE @datos NVARCHAR(MAX) = (SELECT data FROM @json);

    ----------------------------------------------------------------
    -- 6️) Interpretación del JSON con OPENJSON
    ----------------------------------------------------------------
    -- Se navega a:
    -- $.daily.temperature_2m_max
    -- y se obtiene el primer valor del arreglo [0]
    ----------------------------------------------------------------
    DECLARE @tempMax DECIMAL(5,2);

    SELECT @tempMax = temperature
    FROM OPENJSON(@datos, '$.daily.temperature_2m_max')
    WITH (
        temperature DECIMAL(5,2) '$[0]'
    );

    ----------------------------------------------------------------
    -- 7️)Regla de negocio
    ----------------------------------------------------------------
    -- Si temperatura >= 30°C:
    --     Se recomienda aumentar stock de frutas estivales.
    -- Caso contrario:
    --     Se indica demanda normal.
    ----------------------------------------------------------------
    IF @tempMax >= 30
    BEGIN
        SELECT
            @tempMax AS TemperaturaMaxima,
            'Alta demanda esperada. Reforzar stock de sandía, melón y frutas de verano.' AS Recomendacion
        FOR XML PATH('Clima'), ROOT('RecomendacionClimatica');
    END
    ELSE
    BEGIN
        SELECT
            @tempMax AS TemperaturaMaxima,
            'Demanda normal. No se requiere ajuste especial.' AS Recomendacion
        FOR XML PATH('Clima'), ROOT('RecomendacionClimatica');
    END

END
GO



